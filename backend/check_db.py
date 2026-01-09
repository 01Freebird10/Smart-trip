
import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

from allauth.socialaccount.models import SocialApp
from django.contrib.sites.models import Site
from django.conf import settings

def check_db():
    print(f"--- CHECKING DATABASE (Site ID: {settings.SITE_ID}) ---")
    
    # Check Site
    try:
        site = Site.objects.get(pk=settings.SITE_ID)
        print(f"[OK] Current Site: ID={site.id}, Domain={site.domain}, Name={site.name}")
    except Site.DoesNotExist:
        print(f"[FAIL] Site with ID {settings.SITE_ID} DOES NOT EXIST!")

    # Check SocialApp
    apps = SocialApp.objects.filter(provider='google')
    if not apps.exists():
        print("[FAIL] No Google SocialApp found!")
    else:
        for app in apps:
            print(f"[OK] Found App: {app.name} (Client ID: {app.client_id[:10]}...)")
            sites = app.sites.all()
            if site in sites:
                print("   -> [PASS] Linked to current Site.")
            else:
                print("   -> [FAIL] NOT linked to current Site!")

if __name__ == "__main__":
    check_db()
