import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from policies.models import Policy

# Update existing policies to set balance = device value
policies = Policy.objects.all()

print(f"Updating {policies.count()} policies...")

for policy in policies:
    old_balance = policy.policy_balance
    policy.policy_balance = policy.device_package.device_value
    policy.save()
    print(f"Policy {policy.policy_number}: {old_balance} -> {policy.policy_balance}")

print("\nDone! All policy balances updated.")
