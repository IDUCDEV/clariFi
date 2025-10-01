-- Enable pgcrypto extension for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Users Table
CREATE TABLE public.users (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email text UNIQUE NOT NULL,
    user_name text,
    full_name text,
    locale text,
    currency text DEFAULT ''USD'',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz
);

-- Accounts Table
CREATE TABLE public.accounts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
    name text NOT NULL,
    type text CHECK (type IN ('cash', 'bank', 'card', 'wallet', 'other')),
    currency text,
    balance numeric(14, 2) DEFAULT 0,
    is_default boolean DEFAULT false,
    created_at timestamptz DEFAULT now()
);

-- Categories Table
CREATE TABLE public.categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
    name text NOT NULL,
    type text CHECK (type IN ('expense', 'income', 'transfer')) NOT NULL,
    color text,
    icon text,
    created_at timestamptz DEFAULT now()
);

-- Transactions Table
CREATE TABLE public.transactions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
    account_id uuid REFERENCES public.accounts(id),
    category_id uuid REFERENCES public.categories(id),
    type text CHECK (type IN ('expense', 'income', 'transfer')) NOT NULL,
    amount numeric(14, 2) NOT NULL CHECK (amount >= 0),
    currency text,
    note text,
    date date NOT NULL,
    recurring_rule text,
    metadata jsonb,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz
);

-- Budgets Table
CREATE TABLE public.budgets (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
    name text,
    category_id uuid REFERENCES public.categories(id),
    amount numeric(14, 2) NOT NULL,
    period text CHECK (period IN ('monthly', 'weekly', 'yearly')) DEFAULT 'monthly',
    start_date date,
    end_date date,
    alert_threshold numeric(5, 2),
    created_at timestamptz DEFAULT now()
);

-- Notifications Table
CREATE TABLE public.notifications (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
    type text CHECK (type IN ('budget_alert', 'low_balance', 'reminder', 'custom')),
    payload jsonb,
    delivered boolean DEFAULT false,
    delivered_at timestamptz,
    scheduled_at timestamptz
);

-- Exports Table
CREATE TABLE public.exports (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
    type text CHECK (type IN ('csv', 'pdf')),
    file_path text,
    params jsonb,
    created_at timestamptz DEFAULT now()
);

-- Function to create a user profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, user_name, full_name, locale, currency)
  VALUES (new.id, new.email, new.user_name, new.full_name, new.locale, new.currency);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call the function when a new user is created in auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- RLS Policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only see their own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own accounts" ON public.accounts FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own categories" ON public.categories FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own transactions" ON public.transactions FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own budgets" ON public.budgets FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own notifications" ON public.notifications FOR ALL USING (auth.uid() = user_id);

ALTER TABLE public.exports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own exports" ON public.exports FOR ALL USING (auth.uid() = user_id);
