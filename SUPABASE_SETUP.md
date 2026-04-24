# Supabase Setup

## 1. Create the project
- Create a Supabase project.
- Open the SQL editor and run [supabase/schema.sql](./supabase/schema.sql).

## 2. Auth settings
- Go to `Authentication -> Providers -> Email`.
- If you want the shared account to work immediately without email confirmation, disable `Confirm email`.

## 3. Get your keys
- Project URL
- Publishable key / anon key

## 4. Run Flutter with the keys
```bash
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

## 5. Run web
```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

## 6. Shared account model
- Create one shared email and password.
- Log in with the same credentials on both phones and on the website.
- The budget data is stored in Supabase under that shared auth user.
