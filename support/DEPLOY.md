# Deploy Support Page to GitHub Pages

## Quick Deploy (5 minutes)

### Option 1: Create a New Repository

1. **Go to GitHub and create a new repository:**
   - Name: `flowiq-support` (or any name)
   - Set to Public
   - Don't initialize with README

2. **Push the support page:**
```bash
cd /Users/ronos/Workspace/Projects/Active/ZyraFlow/support
git init
git add index.html
git commit -m "Initial support page"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/flowiq-support.git
git push -u origin main
```

3. **Enable GitHub Pages:**
   - Go to repository Settings
   - Scroll to "Pages" section
   - Source: Deploy from a branch
   - Branch: `main` / `root`
   - Click Save

4. **Your support page will be live at:**
   ```
   https://YOUR_USERNAME.github.io/flowiq-support/
   ```

### Option 2: Use Existing ZyraFlow Repository

1. **Commit and push the support folder:**
```bash
cd /Users/ronos/Workspace/Projects/Active/ZyraFlow
git add support/
git commit -m "Add support page"
git push
```

2. **Enable GitHub Pages:**
   - Go to ZyraFlow repository Settings
   - Scroll to "Pages" section
   - Source: Deploy from a branch
   - Branch: `main` / `support`
   - Click Save

3. **Your support page will be at:**
   ```
   https://YOUR_USERNAME.github.io/ZyraFlow/support/
   ```

## Custom Domain (Optional)

If you own `flowiq.app`:

1. Create a `CNAME` file in the support folder:
```bash
echo "support.flowiq.app" > CNAME
```

2. Add DNS record in your domain provider:
   - Type: `CNAME`
   - Name: `support`
   - Value: `YOUR_USERNAME.github.io`

3. In GitHub Pages settings, set custom domain to `support.flowiq.app`

## For App Store Connect

Use one of these URLs:
- GitHub Pages: `https://YOUR_USERNAME.github.io/flowiq-support/`
- Custom domain: `https://support.flowiq.app/`

## Alternative: Quick Deploy with Netlify Drop

1. Go to https://app.netlify.com/drop
2. Drag the `support` folder
3. Get instant URL: `https://random-name.netlify.app`
4. Use this URL in App Store Connect

Choose the method that works best for you!
