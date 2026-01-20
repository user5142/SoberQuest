# Legal Documents for SoberQuest

This folder contains the Privacy Policy and Terms of Use for SoberQuest. These documents are required for iOS App Store submission and compliance with Apple's guidelines.

## Files Included

1. **PRIVACY_POLICY.md** - Comprehensive privacy policy compliant with:
   - Apple App Store requirements
   - CCPA (California Consumer Privacy Act)
   - General privacy best practices for health/wellness apps
   - iOS data collection disclosure requirements

2. **TERMS_OF_USE.md** - Complete terms of service covering:
   - User eligibility and license
   - Medical disclaimer (important for addiction tracking apps)
   - Subscription and payment terms
   - Apple-specific requirements
   - Liability limitations and legal protections

## Action Items

### 1. Customize Placeholder Information

Both documents contain placeholders that you need to replace:

- `[YOUR COMPANY NAME]` - Your legal business entity name
- `[YOUR SUPPORT EMAIL]` - Your customer support email address
- `[YOUR WEBSITE URL]` - Your company/studio website URL
- `[YOUR STATE/COUNTRY]` - Jurisdiction for legal disputes (e.g., "California" or "United States")
- `[YOUR LOCATION]` - Location for venue/jurisdiction (e.g., "San Francisco, California")
- `[YOUR PHYSICAL ADDRESS]` - Your business address (required for legal notices)

### 2. Host on Your Website

1. Create pages on your studio website for both documents:
   - `https://yourwebsite.com/privacy-policy`
   - `https://yourwebsite.com/terms-of-use`

2. Convert the Markdown files to HTML and publish them on your website

3. Ensure these pages are publicly accessible (no login required)

### 3. Update App Links

After hosting the documents on your website, update the URLs in the app:

**File**: `SoberQuest/App/SoberQuestApp.swift`

**Privacy Policy Link** (around line 222):
```swift
if let url = URL(string: "https://yourwebsite.com/privacy-policy") {
    UIApplication.shared.open(url)
}
```

**Terms of Use Link** (around line 233):
```swift
if let url = URL(string: "https://yourwebsite.com/terms-of-use") {
    UIApplication.shared.open(url)
}
```

### 4. App Store Submission

When submitting to the App Store:

1. In App Store Connect, you'll need to provide URLs to both documents
2. Make sure the URLs are accessible before submission
3. Apple reviewers will check these links during the review process

Required fields in App Store Connect:
- **Privacy Policy URL**: Link to your hosted privacy policy
- **Terms of Use URL**: Link to your hosted terms of use (optional but recommended)

### 5. Legal Review (Recommended)

While these documents are comprehensive and follow industry best practices, you should consider:

1. Having a lawyer review them for your specific situation
2. Ensuring compliance with your local jurisdiction's laws
3. Customizing sections based on your specific business practices
4. Keeping them updated as your app evolves

## Key Points for SoberQuest

### Medical Disclaimer
The Terms of Use includes a strong medical disclaimer stating that SoberQuest is NOT a substitute for professional medical advice. This is critical for addiction tracking apps to limit liability.

### Health Data Privacy
The Privacy Policy explicitly addresses:
- How addiction tracking data is stored (locally on device)
- What data is shared with third parties (only subscription info)
- User rights to access, edit, and delete their data
- Compliance with health/wellness data protection requirements

### Subscription Terms
Detailed subscription terms covering:
- Free trial period
- Automatic renewal
- Cancellation and refund policy
- Apple's role in payment processing

### Age Restriction
Both documents specify the app is for users 17+, consistent with addiction recovery app guidelines.

## Testing the Links

After updating the URLs:

1. Build and run the app in Xcode
2. Navigate to Settings (gear icon in Home screen)
3. Scroll to the "Legal" section
4. Tap "Privacy Policy" - should open your website in Safari
5. Tap "Terms of Use" - should open your website in Safari

## App Store Review Guidelines

These documents help comply with:

- **Guideline 1.3**: Kids Category (marking as 17+ due to content)
- **Guideline 2.5.14**: Credits and App Store Requirements
- **Guideline 5.1.1**: Privacy and Data Collection
- **Guideline 5.1.2**: Data Use and Sharing

## Updates and Versioning

- Both documents are dated January 20, 2026 (Version 1.0.0)
- When you update them, change the "Last Updated" date at the top
- Notify users of material changes through an in-app notification
- Keep previous versions archived for your records

## Questions?

If you need to customize these documents further or have specific legal requirements, consult with an attorney familiar with:
- Mobile app law
- Health and wellness apps
- HIPAA compliance (if applicable)
- State-specific privacy laws (CCPA, VCDPA, etc.)

---

**Note**: These documents are templates and should be reviewed by legal counsel before use. They are designed to be comprehensive but may need adjustments based on your specific circumstances, jurisdiction, and business practices.
