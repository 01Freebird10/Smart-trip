
import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

from django.contrib.sites.models import Site
from allauth.socialaccount.models import SocialApp
from django.conf import settings

print(f"--- DEBUGGING CONFIGURATION ---")
print(f"Current settings.SITE_ID: {settings.SITE_ID}")

print("\n--- SITES IN DATABASE ---")
sites = Site.objects.all()
for site in sites:
    print(f"ID: {site.id} | Domain: {site.domain} | Name: {site.name}")

print("\n--- SOCIAL APPS IN DATABASE ---")
apps = SocialApp.objects.all()
if not apps:
    print("NO SOCIAL APPS FOUND! Please create one in /admin")
else:
    for app in apps:
        print(f"App ID: {app.id} | Provider: {app.provider} | Name: {app.name} | Client ID: {app.client_id}")
        linked_sites = app.sites.all()
        print(f"  -> Linked to Sites: {[s.id for s in linked_sites]}")
        
        if settings.SITE_ID in [s.id for s in linked_sites]:
             print("  [OK] This app is correctly linked to the current SITE_ID.")
        else:
             print(f"  [ERROR] This app is NOT linked to Site ID {settings.SITE_ID}!")

print("\n------------------------------")
