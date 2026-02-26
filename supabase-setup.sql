-- Run this entire block in your Supabase SQL Editor
-- Go to: your project → SQL Editor → New Query → paste this → Run

-- PROFILES TABLE (one row per user)
create table if not exists profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  username    text unique not null,
  elo         integer default 1000,
  wins        integer default 0,
  losses      integer default 0,
  best_score  integer,
  rank_tier   text default 'Bronze',
  created_at  timestamptz default now()
);

-- CLAIMS TABLE (debate claims posted by users)
create table if not exists claims (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references profiles(id) on delete cascade,
  claim       text not null,
  category    text not null,
  status      text default 'pending',  -- pending | active | debated
  created_at  timestamptz default now()
);

-- ROW LEVEL SECURITY (so users can only see/edit their own data)
alter table profiles enable row level security;
alter table claims   enable row level security;

-- Profiles: users can read all profiles, but only update their own
create policy "Public profiles are viewable" on profiles for select using (true);
create policy "Users can update own profile"  on profiles for update using (auth.uid() = id);
create policy "Users can insert own profile"  on profiles for insert with check (auth.uid() = id);

-- Claims: users can read all claims, insert their own
create policy "Claims are viewable by all"   on claims for select using (true);
create policy "Users can insert own claims"  on claims for insert with check (auth.uid() = user_id);
create policy "Users can update own claims"  on claims for update using (auth.uid() = user_id);
