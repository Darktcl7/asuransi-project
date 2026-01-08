import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from claims.models import ClaimPhoto, Claim

print('=== Database Check ===')
print(f'Total Claims: {Claim.objects.count()}')
print(f'Total ClaimPhotos: {ClaimPhoto.objects.count()}')
print()
print('=== Claims with Photo Count ===')
for claim in Claim.objects.all().order_by('-created_at')[:10]:
    photo_count = claim.photos.count()
    print(f'{claim.claim_number}: {photo_count} photos - Status: {claim.status}')
