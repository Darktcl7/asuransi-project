import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/wallet_transaction.dart';
import '../../widgets/shimmer_card.dart';

class WalletHistoryScreen extends StatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<WalletTransaction> _transactions = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, topup, deduction, policy_purchase

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      final transactionsJson = await _apiService.getWalletHistory();
      
      print('Wallet history response: $transactionsJson'); // Debug log
      
      setState(() {
        _transactions = transactionsJson
            .map((json) {
              try {
                return WalletTransaction.fromJson(json);
              } catch (e) {
                print('Error parsing transaction: $e');
                print('JSON: $json');
                return null;
              }
            })
            .whereType<WalletTransaction>() // Filter out nulls
            .toList();
        // Already sorted by created_at descending from backend
        _isLoading = false;
      });
    } catch (e) {
      print('Load transactions error: $e'); // Debug log
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memuat riwayat: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<WalletTransaction> get _filteredTransactions {
    if (_filterType == 'all') return _transactions;
    return _transactions
        .where((t) => t.transactionType.toLowerCase() == _filterType)
        .toList();
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'topup':
        return Colors.green;
      case 'deduction':
      case 'policy_purchase':
        return Colors.red;
      case 'refund':
        return Colors.blue;
      case 'adjustment':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'topup':
        return Icons.add_circle;
      case 'deduction':
        return Icons.remove_circle;
      case 'policy_purchase':
        return Icons.shopping_cart;
      case 'refund':
        return Icons.refresh;
      case 'adjustment':
        return Icons.tune;
      default:
        return Icons.swap_horiz;
    }
  }

  String _formatCurrency(double value) {
    try {
      return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    } catch (e) {
      return 'Rp 0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(),

          // Transactions List
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 6,
                    itemBuilder: (context, index) => const ShimmerPolicyCard(),
                  )
                : _filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTransactions,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _filteredTransactions[index];
                            return _buildTransactionCard(transaction);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Semua', 'all', _transactions.length),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Top Up',
              'topup',
              _transactions.where((t) => t.transactionType == 'topup').length,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Beli Polis',
              'policy_purchase',
              _transactions.where((t) => t.transactionType == 'policy_purchase').length,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Potongan',
              'deduction',
              _transactions.where((t) => t.transactionType == 'deduction').length,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filterType == value;
    
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = value;
        });
      },
      selectedColor: Colors.indigo.shade100,
      checkmarkColor: Colors.indigo,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.indigo : Colors.black87,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _filterType == 'all'
                ? 'Belum Ada Transaksi'
                : 'Tidak Ada Transaksi $_filterType',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat transaksi Anda akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(WalletTransaction transaction) {
    final typeColor = _getTypeColor(transaction.transactionType);
    final isCredit = transaction.isCredit;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showTransactionDetail(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTypeIcon(transaction.transactionType),
                  color: typeColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Transaction Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Label
                    Text(
                      transaction.typeLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Description
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Date
                    Text(
                      transaction.formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isCredit ? '+' : '-'} ${transaction.formattedAmount}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCredit ? 'CREDIT' : 'DEBIT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetail(WalletTransaction transaction) {
    final typeColor = _getTypeColor(transaction.transactionType);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title with Icon
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTypeIcon(transaction.transactionType),
                      color: typeColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Transaksi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          transaction.typeLabel,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Transaction Details
              _buildDetailRow('Jumlah', 
                  '${transaction.isCredit ? '+' : '-'} ${transaction.formattedAmount}',
                  transaction.isCredit ? Colors.green : Colors.red),
              _buildDetailRow('Saldo Sebelum', transaction.formattedBalanceBefore),
              _buildDetailRow('Saldo Setelah', transaction.formattedBalanceAfter, Colors.indigo),
              _buildDetailRow('Tanggal', transaction.formattedDate),
              
              const SizedBox(height: 16),
              
              Text(
                'Deskripsi:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              if (transaction.referenceId != null) ...[
                const SizedBox(height: 16),
                _buildDetailRow('Reference ID', transaction.referenceId!),
                if (transaction.referenceType != null)
                  _buildDetailRow('Reference Type', transaction.referenceType!),
              ],

              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
