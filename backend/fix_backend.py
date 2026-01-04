import os
import django
from django.core.management import call_command

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from users.models import User
from trips.models import Trip

def fix_all():
    print("--- Fixing Backend State ---")
    
    # 1. Run Migrations
    print("Generating and running migrations...")
    call_command('makemigrations', 'trips', no_input=True)
    call_command('migrate', no_input=True)
    
    # 2. Ensure Demo User
    email = 'explorer@smartplanner.io'
    password = 'demo123'
    user, created = User.objects.get_or_create(email=email)
    if created:
        user.set_password(password)
        user.first_name = 'Demo'
        user.last_name = 'Explorer'
        user.save()
        print(f"Created demo user: {email}")
    else:
        user.set_password(password)
        user.save()
        print(f"Updated demo user password: {email}")

    # 3. Create Media Directories
    media_root = django.conf.settings.MEDIA_ROOT
    for sub in ['trips', 'profiles']:
        path = os.path.join(media_root, sub)
        if not os.path.exists(path):
            os.makedirs(path)
            print(f"Created media directory: {path}")

    print("--- Backend Fixed ---")

if __name__ == '__main__':
    fix_all()
