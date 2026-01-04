import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from trips.models import Trip
from users.models import User

print(f"Total Users: {User.objects.count()}")
print(f"Total Trips: {Trip.objects.count()}")

for trip in Trip.objects.all():
    print(f"Trip ID: {trip.id}, Title: {trip.title}, Owner: {trip.owner.email if trip.owner else 'None'}")
