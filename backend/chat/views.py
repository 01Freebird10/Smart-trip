from rest_framework import generics, permissions
from .models import Message
from .serializers import MessageSerializer

class MessageHistoryView(generics.ListAPIView):
    serializer_class = MessageSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        trip_id = self.request.query_params.get('trip_id')
        return Message.objects.filter(trip_id=trip_id)
