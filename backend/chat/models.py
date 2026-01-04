from django.db import models
from django.conf import settings
from trips.models import Trip

class Message(models.Model):
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='messages')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['timestamp']

    def __str__(self):
        return f'{self.user.email}: {self.content[:20]}'
