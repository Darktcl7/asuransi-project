# wallet/admin.py
from django.contrib import admin
from .models import Wallet, TopUpTransaction, WalletHistory

admin.site.register(Wallet)
admin.site.register(TopUpTransaction)
admin.site.register(WalletHistory)