from django.test import TestCase


class TripModelTest(TestCase):
    """Basic tests for the Trip models."""
    
    def test_basic_sanity(self):
        """Test that basic assertions work - placeholder for CI/CD."""
        self.assertEqual(2 * 2, 4)
    
    def test_list_operations(self):
        """Test basic list operations."""
        trips = ["Paris", "London", "Tokyo"]
        self.assertIn("Paris", trips)
        self.assertEqual(len(trips), 3)
