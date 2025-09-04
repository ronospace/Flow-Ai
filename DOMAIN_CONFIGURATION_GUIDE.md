# Domain Configuration Guide: flowai.app

## Overview
Complete setup guide for configuring the `flowai.app` domain for the Flow Ai application.

## 🌐 Step 1: Domain Registration

### Purchase Domain
1. **Register flowai.app domain** (if not already done)
   - Recommended registrars: Namecheap, Google Domains, GoDaddy
   - Ensure you have admin access to DNS settings

### Verify Domain Ownership
```bash
# Check current DNS settings
dig flowai.app
nslookup flowai.app
```

## 🔧 Step 2: Firebase Hosting Domain Setup

### Add Custom Domain in Firebase Console
1. **Navigate to Firebase Hosting:**
   ```
   Firebase Console → flowai-production → Hosting → Add custom domain
   ```

2. **Add Domain:**
   - Domain: `flowai.app`
   - Also add: `www.flowai.app` (recommended)

3. **Verify Domain Ownership:**
   - Firebase will provide a TXT record
   - Add to your DNS provider:
   ```
   Type: TXT
   Name: @
   Value: [Firebase verification code]
   TTL: 300
   ```

### DNS Configuration
Add the following DNS records at your domain registrar:

#### Primary Domain (flowai.app)
```
Type: A
Name: @
Value: 151.101.1.195
TTL: 300

Type: A  
Name: @
Value: 151.101.65.195
TTL: 300
```

#### WWW Subdomain (www.flowai.app)
```
Type: CNAME
Name: www
Value: flowai-production.web.app.
TTL: 300
```

#### SSL Certificate
Firebase automatically provisions SSL certificates for custom domains.

## 📧 Step 3: Email Configuration (Optional)

### Professional Email Setup
If you want professional email addresses (`contact@flowai.app`, `support@flowai.app`):

#### Option A: Google Workspace
1. Set up Google Workspace for flowai.app
2. Add MX records:
```
Type: MX
Name: @
Value: 1 smtp.google.com.
TTL: 300

Type: MX
Name: @  
Value: 5 smtp2.google.com.
TTL: 300

Type: MX
Name: @
Value: 10 smtp3.google.com.
TTL: 300
```

#### Option B: Email Forwarding
Simple email forwarding to existing addresses:
```
Type: MX
Name: @
Value: 10 mail.forwardemail.net.
TTL: 300

Type: TXT
Name: @
Value: forward-email=your-email@gmail.com
TTL: 300
```

## 🔐 Step 4: Security Headers

### Add Security TXT Records
```
Type: TXT
Name: @
Value: v=spf1 include:_spf.google.com ~all
TTL: 300

Type: TXT  
Name: @
Value: v=DMARC1; p=quarantine; rua=mailto:dmarc@flowai.app
TTL: 300
```

### DKIM (if using Google Workspace)
Google Workspace will provide DKIM records to add.

## 🚀 Step 5: API and Services Configuration

### API Endpoints
If you have backend services, configure subdomains:

```
# API subdomain
Type: CNAME
Name: api
Value: your-api-server.com.
TTL: 300

# Admin panel subdomain  
Type: CNAME
Name: admin
Value: your-admin-panel.com.
TTL: 300
```

### Firebase Functions Domain (if using)
```
Type: CNAME
Name: api
Value: us-central1-flowai-production.cloudfunctions.net.
TTL: 300
```

## ✅ Step 6: Verification and Testing

### Domain Propagation Check
```bash
# Check DNS propagation globally
dig @8.8.8.8 flowai.app
dig @1.1.1.1 flowai.app

# Use online tools
# https://dnschecker.org/
# https://www.whatsmydns.net/
```

### SSL Certificate Verification
```bash
# Check SSL certificate
openssl s_client -connect flowai.app:443 -servername flowai.app

# Or use online SSL checker
# https://www.ssllabs.com/ssltest/
```

### HTTP/HTTPS Redirects
Ensure proper redirects are configured:
- `http://flowai.app` → `https://flowai.app`
- `https://www.flowai.app` → `https://flowai.app` (or vice versa)

## 📱 Step 7: Mobile App Configuration

### Deep Links Configuration
Update app configuration for deep links:

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="flowai.app" />
</intent-filter>
```

#### iOS (ios/Runner/Info.plist)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>flowai.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>https</string>
        </array>
    </dict>
</array>
```

### Universal Links
Create `.well-known/apple-app-site-association` file in Firebase Hosting:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.flowai.health",
        "paths": ["*"]
      }
    ]
  }
}
```

## 🔍 Step 8: Analytics and Monitoring

### Google Analytics
Update Google Analytics property:
- Property name: "Flow Ai"
- Website URL: https://flowai.app

### Google Search Console
1. Add flowai.app property
2. Verify ownership via DNS TXT record
3. Submit sitemap: https://flowai.app/sitemap.xml

### Domain Performance Monitoring
Set up monitoring for:
- Domain resolution time
- SSL certificate expiration
- Website uptime
- Page load speed

## 📊 Step 9: SEO Configuration

### Meta Tags Updates
Update meta tags in web app:
```html
<meta property="og:url" content="https://flowai.app">
<meta property="og:site_name" content="Flow Ai">
<meta name="twitter:domain" content="flowai.app">
<link rel="canonical" href="https://flowai.app">
```

### Robots.txt
Create/update robots.txt:
```
User-agent: *
Allow: /

Sitemap: https://flowai.app/sitemap.xml
```

## 🚨 Step 10: Migration from Old Domain

### Redirect Configuration
If migrating from zyraflow.app:

1. **Set up 301 redirects:**
```
zyraflow.app → flowai.app
www.zyraflow.app → www.flowai.app
```

2. **Update all references:**
   - Social media profiles
   - Business listings
   - Documentation
   - Email signatures

### Search Engine Updates
1. **Google Search Console:**
   - Submit change of address
   - Update sitemaps
   - Monitor crawl errors

2. **Social Media:**
   - Update website URLs on all platforms
   - Update bio links

## ✅ Verification Checklist

- [ ] Domain registered and DNS configured
- [ ] Firebase Hosting custom domain added
- [ ] SSL certificate active and valid
- [ ] Email forwarding/workspace configured (if applicable)
- [ ] Deep links working in mobile apps
- [ ] Universal links configured for iOS
- [ ] Analytics tracking updated
- [ ] Search Console property added
- [ ] All redirects working properly
- [ ] Performance monitoring set up

## 🛠️ Troubleshooting

### Common Issues:

1. **DNS Propagation Delays:**
   - Wait 24-48 hours for full propagation
   - Use different DNS servers to test

2. **SSL Certificate Issues:**
   - Ensure DNS records are correct
   - Wait for Firebase to provision certificate

3. **Deep Links Not Working:**
   - Verify domain verification files
   - Check mobile app configurations

4. **Email Not Working:**
   - Verify MX records
   - Check DNS propagation
   - Test with email testing tools

### Support Resources:
- Firebase Hosting Documentation
- Google Domains Support
- DNS propagation checkers
- SSL certificate validators

---

**⚠️ Important Notes:**
- DNS changes can take 24-48 hours to fully propagate
- Keep old domain active during transition period
- Monitor analytics for any traffic drops
- Test all functionality after domain changes
