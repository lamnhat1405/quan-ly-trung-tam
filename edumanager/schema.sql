-- Chạy toàn bộ file này trong Supabase → SQL Editor
create table profiles(id uuid primary key references auth.users on delete cascade,full_name text,email text,role text default 'giaovien' check(role in('admin','quanly','sale','giaovu','ketoan','giaovien')));
create table settings(id int primary key default 1,center_name text default 'Trung tâm',hotline text,address text,email text,bank_code text,account_no text,account_name text,due_day int default 5);
insert into settings(id) values(1);
create table leads(id bigint generated always as identity primary key,name text not null,phone text not null,email text,source text,status text default 'Mới',owner text,note text,created_at timestamptz default now());
create table tests(id bigint generated always as identity primary key,name text not null,phone text,date date,teacher_id bigint,status text default 'Đã hẹn',result text);
create table courses(id bigint generated always as identity primary key,name text not null,fee_month numeric default 0,sessions int,teacher_rate numeric,descr text);
create table rooms(id bigint generated always as identity primary key,name text not null,capacity int,floor text,status text default 'Sẵn sàng');
create table teachers(id bigint generated always as identity primary key,name text not null,email text,phone text,subject text,contract text,rate numeric default 0,base_salary numeric default 0,status text default 'Hoạt động');
create table classes(id bigint generated always as identity primary key,name text not null,course_id bigint references courses,teacher_id bigint references teachers,room_id bigint references rooms,start_date date,total_sessions int default 24,max_students int default 15,schedule text,status text default 'Sắp khai giảng');
create table students(id bigint generated always as identity primary key,name text not null,phone text,email text,dob date,address text,class_id bigint references classes,lead_id bigint,status text default 'Đang học',note text,created_at timestamptz default now());
create table invoices(id bigint generated always as identity primary key,student_id bigint references students on delete cascade,title text,amount numeric not null,paid numeric default 0,due_date date);
create table payments(id bigint generated always as identity primary key,invoice_id bigint references invoices on delete set null,student_id bigint,amount numeric not null,method text,note text,created_by text,created_at timestamptz default now());
create table attendance(id bigint generated always as identity primary key,class_id bigint references classes on delete cascade,student_id bigint references students on delete cascade,date date,status text,unique(class_id,student_id,date));
create table payroll(id bigint generated always as identity primary key,teacher_id bigint references teachers on delete cascade,month text,bonus numeric default 0,deduction numeric default 0,note text,unique(teacher_id,month));

create function auth_role() returns text language sql security definer stable as $$select case when role='quanly' then 'admin' else role end from profiles where id=auth.uid()$$;
create function on_signup() returns trigger language plpgsql security definer as $$begin
insert into profiles(id,email,full_name,role) values(new.id,new.email,coalesce(new.raw_user_meta_data->>'full_name',new.email),case when (select count(*) from profiles)=0 then 'admin' else 'giaovien' end);return new;end$$;
create trigger t_signup after insert on auth.users for each row execute function on_signup();

alter table profiles enable row level security;
create policy p_r on profiles for select to authenticated using(true);
create policy p_w on profiles for all to authenticated using(auth_role()='admin') with check(auth_role()='admin');

do $$ declare t record; begin
for t in select * from (values
 ('leads','{admin,sale,giaovu,ketoan}','{admin,sale}'),
 ('tests','{admin,sale,giaovu,giaovien}','{admin,sale,giaovien}'),
 ('courses','{admin,sale,giaovu,ketoan,giaovien}','{admin}'),
 ('rooms','{admin,sale,giaovu,ketoan,giaovien}','{admin,giaovu}'),
 ('teachers','{admin,sale,giaovu,ketoan,giaovien}','{admin}'),
 ('classes','{admin,sale,giaovu,ketoan,giaovien}','{admin,giaovu}'),
 ('students','{admin,sale,giaovu,ketoan,giaovien}','{admin,sale,giaovu}'),
 ('invoices','{admin,sale,giaovu,ketoan}','{admin,sale,ketoan}'),
 ('payments','{admin,ketoan}','{admin,ketoan}'),
 ('attendance','{admin,sale,giaovu,ketoan,giaovien}','{admin,giaovu,giaovien}'),
 ('payroll','{admin,ketoan}','{admin,ketoan}'),
 ('settings','{admin,sale,giaovu,ketoan,giaovien}','{admin}')
) v(n,r,w) loop
 execute format('alter table %I enable row level security',t.n);
 execute format('create policy %I on %I for select to authenticated using(auth_role()=any(%L::text[]))','r_'||t.n,t.n,t.r);
 execute format('create policy %I on %I for all to authenticated using(auth_role()=any(%L::text[])) with check(auth_role()=any(%L::text[]))','w_'||t.n,t.n,t.w,t.w);
end loop; end $$;
