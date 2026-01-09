
import os
import sys
import django

# Setup Django environment
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

from django.contrib.sites.models import Site
from allauth.socialaccount.models import SocialApp
from django.conf import settings

# Extracted from your index.html
CLIENT_ID = "599186631238-6kgouftgun9a571fqrhuhdcfj5au7l18.apps.googleusercontent.com"

def run():
    print("--- FIXING GOOGLE AUTH ---")
    
    # 1. Get the Client Secret
    if len(sys.argv) < 2:
        print("\nERROR: Missing Client Secret!")
        print("Please run this script with your Google Client Secret as an argument.")
        print('Example: python setup_google.py "YOUR_SECRET_KEY_HERE"')
        return

    secret_key = sys.argv[1]

    # 2. Configure the Site (localhost:8000)
    # settings.SITE_ID is usually 1
    try:
        site = Site.objects.get(id=settings.SITE_ID)
        site.domain = "localhost:8000"
        site.name = "localhost"
        site.save()
        print(f"[OK] Site configured: ID={site.id}, Domain={site.domain}")
    except Site.DoesNotExist:
        print(f"[ERROR] Site with ID {settings.SITE_ID} not found! Please check your database.")
        return

    # 3. Create or Update the Google SocialApp
    app, created = SocialApp.objects.get_or_create(
        provider="google",
        defaults={
            "name": "Google Login",
            "client_id": CLIENT_ID,
            "secret": secret_key,
        }
    )

    if not created:
        print("[INFO] Google App already exists. Updating credentials...")
        app.client_id = CLIENT_ID
        app.secret = secret_key
        app.save()
    else:
        print("[OK] Created new Google SocialApp.")

    # 4. Link App to Site
    if site not in app.sites.all():
        app.sites.add(site)
        print("[OK] Linked Google App to Site.")
    else:
        print("[OK] Google App is already linked to Site.")

    print("\nSUCCESS! Backend is now ready for Google Login.")

if __name__ == "__main__":
    run()
