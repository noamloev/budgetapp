# Render Web Deploy

This project can be deployed as a free Render static site.

## 1. Push the project to GitHub
- Create a GitHub repository.
- Push the whole Flutter project to it.

## 2. Create the Render site
- Go to `https://render.com`
- Click `New`
- Click `Blueprint`
- Select your GitHub repository

Render will read [render.yaml](./render.yaml).

## 3. Add environment variables in Render
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Use the same values you already use locally.

## 4. Deploy
- Click `Apply`
- Wait for the build to finish

## 5. Public URL
Render will give you a public URL like:

`https://budget-flow.onrender.com`

or another unique `onrender.com` URL if that name is already taken.

## 6. Shared login
- Register once with the shared email/password
- Then log in from Android or the website using the same credentials
- Different login credentials mean a completely different budget
