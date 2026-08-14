import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/pb_api.dart';

class DSACodeItem {
  String code;
  String label;
  bool isActive;

  DSACodeItem({
    required this.code,
    required this.label,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'label': label,
        'active': isActive,
      };

  factory DSACodeItem.fromJson(Map<String, dynamic> json) => DSACodeItem(
        code: json['code']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        isActive: json['active'] != false,
      );
}

class SMCodeItem {
  String name;
  String code;
  bool isActive;

  SMCodeItem({
    required this.name,
    required this.code,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'active': isActive,
      };

  factory SMCodeItem.fromJson(Map<String, dynamic> json) => SMCodeItem(
        name: json['name']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        isActive: json['active'] != false,
      );
}

class DSECodeItem {
  String dseCode;
  String dseName;
  String dsaCode;
  String smCode;
  bool forVendor;
  bool isActive;

  DSECodeItem({
    required this.dseCode,
    required this.dseName,
    required this.dsaCode,
    required this.smCode,
    this.forVendor = false,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'dse_code': dseCode,
        'dse_name': dseName,
        'dsa_code': dsaCode,
        'sm_code': smCode,
        'for_vendor': forVendor,
        'active': isActive,
      };

  factory DSECodeItem.fromJson(Map<String, dynamic> json) => DSECodeItem(
        dseCode: json['dse_code']?.toString() ?? '',
        dseName: json['dse_name']?.toString() ?? '',
        dsaCode: json['dsa_code']?.toString() ?? '',
        smCode: json['sm_code']?.toString() ?? '',
        forVendor: json['for_vendor'] == true || json['is_vendor'] == true,
        isActive: json['active'] != false,
      );
}

class CardConfigItem {
  String cardName;
  String shortCode;
  String baseUrl;
  Map<String, String> smMappings; // SM Code -> DSE Code
  String activeSm;
  bool isActive;

  CardConfigItem({
    required this.cardName,
    required this.shortCode,
    required this.baseUrl,
    required this.smMappings,
    this.activeSm = '',
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'card_name': cardName,
        'short_code': shortCode,
        'base_url': baseUrl,
        'sm_mappings': smMappings,
        'active_sm': activeSm,
        'active': isActive,
      };

  factory CardConfigItem.fromJson(Map<String, dynamic> json) => CardConfigItem(
        cardName: json['card_name']?.toString() ?? '',
        shortCode: json['short_code']?.toString() ?? '',
        baseUrl: json['base_url']?.toString() ?? '',
        smMappings: (json['sm_mappings'] is Map)
            ? Map<String, String>.from(
                (json['sm_mappings'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
              )
            : {},
        activeSm: json['active_sm']?.toString() ?? '',
        isActive: json['active'] != false,
      );
}

class LoginLinkDetailsScreen extends StatefulWidget {
  const LoginLinkDetailsScreen({super.key});

  @override
  State<LoginLinkDetailsScreen> createState() => _LoginLinkDetailsScreenState();
}

class _LoginLinkDetailsScreenState extends State<LoginLinkDetailsScreen> {
  int _currentTabIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _recordId;

  String _dseGroupBy = 'SM'; // 'SM', 'DSA', 'ALL'

  List<DSACodeItem> _dsaCodes = [];
  List<SMCodeItem> _smCodes = [];
  List<DSECodeItem> _dseCodes = [];
  List<CardConfigItem> _cardConfigs = [];
  final Set<String> _expandedCardUrls = {};
  bool _isBulkSwitchExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final records = await PB.pb.collection('bank_url_setting').getFullList();
      if (records.isNotEmpty) {
        final rec = records.first;
        _recordId = rec.id;

        final dsaRaw = rec.data['dsa_codes'];
        if (dsaRaw is List) {
          _dsaCodes = dsaRaw
              .whereType<Map>()
              .map((e) => DSACodeItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          _dsaCodes = [];
        }

        final smRaw = rec.data['sm_codes'];
        if (smRaw is List) {
          _smCodes = smRaw
              .whereType<Map>()
              .map((e) => SMCodeItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          _smCodes = [];
        }

        final dseRaw = rec.data['dse_codes'];
        if (dseRaw is List) {
          _dseCodes = dseRaw
              .whereType<Map>()
              .map((e) => DSECodeItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          _dseCodes = [];
        }

        final cardRaw = rec.data['card_short_codes'];
        if (cardRaw is List) {
          _cardConfigs = cardRaw
              .whereType<Map>()
              .map((e) => CardConfigItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          _cardConfigs = [];
        }
      } else {
        _dsaCodes = [];
        _smCodes = [];
        _dseCodes = [];
        _cardConfigs = [];
      }
    } catch (_) {
      _dsaCodes = [];
      _smCodes = [];
      _dseCodes = [];
      _cardConfigs = [];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final body = {
        'dsa_codes': _dsaCodes.map((e) => e.toJson()).toList(),
        'sm_codes': _smCodes.map((e) => e.toJson()).toList(),
        'dse_codes': _dseCodes.map((e) => e.toJson()).toList(),
        'card_short_codes': _cardConfigs.map((e) => e.toJson()).toList(),
      };

      if (_recordId != null) {
        await PB.pb.collection('bank_url_setting').update(_recordId!, body: body);
      } else {
        final newRec = await PB.pb.collection('bank_url_setting').create(body: body);
        _recordId = newRec.id;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ================= URL COMPILER & SHORTNER SYNC =================
  String _compileCardUrl(CardConfigItem card, String smCode) {
    if (card.baseUrl.trim().isEmpty) return '';

    final dseCode = card.smMappings[smCode] ?? '';
    String dsaCode = '';

    if (dseCode.isNotEmpty) {
      final dseObj = _dseCodes.firstWhere(
        (d) => d.dseCode.toUpperCase() == dseCode.toUpperCase(),
        orElse: () => DSECodeItem(dseCode: dseCode, dseName: '', dsaCode: '', smCode: smCode),
      );
      dsaCode = dseObj.dsaCode;
    }

    if (dsaCode.isEmpty && _dsaCodes.isNotEmpty) {
      dsaCode = _dsaCodes.first.code;
    }

    String compiled = card.baseUrl;

    // Replace standard placeholders
    compiled = compiled
        .replaceAll('{{DSA}}', dsaCode)
        .replaceAll('{DSA}', dsaCode)
        .replaceAll('[DSA]', dsaCode)
        .replaceAll('\$DSA', dsaCode)
        .replaceAll('{{SM}}', smCode)
        .replaceAll('{SM}', smCode)
        .replaceAll('[SM]', smCode)
        .replaceAll('\$SM', smCode)
        .replaceAll('{{DSE}}', dseCode)
        .replaceAll('{DSE}', dseCode)
        .replaceAll('[DSE]', dseCode)
        .replaceAll('\$DSE', dseCode)
        .replaceAll('{{LG}}', dseCode)
        .replaceAll('{LG}', dseCode)
        .replaceAll('{{LC}}', dseCode)
        .replaceAll('{LC}', dseCode)
        .replaceAll('{{LC2}}', dseCode)
        .replaceAll('{LC2}', dseCode);

    return compiled;
  }

  Future<bool> _syncShortnerCollection(String shortCode, String longUrl) async {
    final cleanCode = shortCode.trim().toLowerCase();
    if (cleanCode.isEmpty || longUrl.trim().isEmpty) return false;
    try {
      final existing = await PB.pb.collection('shortner').getFullList(
        filter: 'short_code = "$cleanCode"',
      );
      if (existing.isNotEmpty) {
        await PB.pb.collection('shortner').update(existing.first.id, body: {
          'long_url': longUrl.trim(),
        });
      } else {
        await PB.pb.collection('shortner').create(body: {
          'short_code': cleanCode,
          'long_url': longUrl.trim(),
        });
      }
      return true;
    } catch (e) {
      debugPrint('Error syncing shortner: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shortner update failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  Future<void> _switchCardSM(CardConfigItem card, String smCode) async {
    setState(() {
      card.activeSm = smCode;
    });

    final longUrl = _compileCardUrl(card, smCode);
    await _saveSettings();

    if (longUrl.isNotEmpty && card.shortCode.isNotEmpty) {
      final ok = await _syncShortnerCollection(card.shortCode, longUrl);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('${card.cardName} (${card.shortCode}) ➔ $smCode (Live Updated)')),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF14B8A6),
          ),
        );
      }
    }
  }

  Future<void> _bulkSwitchAll(String smCode) async {
    setState(() => _isSaving = true);
    int switchedCount = 0;

    for (final card in _cardConfigs) {
      if (card.isActive && card.smMappings.containsKey(smCode)) {
        card.activeSm = smCode;
        final longUrl = _compileCardUrl(card, smCode);
        if (longUrl.isNotEmpty && card.shortCode.isNotEmpty) {
          await _syncShortnerCollection(card.shortCode, longUrl);
          switchedCount++;
        }
      }
    }

    await _saveSettings();

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.bolt, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('All $switchedCount active cards switched to SM $smCode!')),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    }
  }

  void _showSwitchConfirmation({
    required CardConfigItem card,
    required SMCodeItem sm,
    required String mappedDse,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFCCFBF1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF0F766E), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Switch Live Manager?',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                        Text(
                          '${card.cardName} (${card.shortCode})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF14B8A6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Target Manager:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        Text('${sm.name} (${sm.code})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mapped DSE:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        Text(mappedDse.isNotEmpty ? mappedDse : 'None', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF14B8A6))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Short Code:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        Text(card.shortCode, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This will immediately re-compile the URL and update the redirect link in shortner.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _switchCardSM(card, sm.code);
                        },
                        child: const Text('Confirm Switch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBulkSwitchConfirmation({required SMCodeItem sm}) {
    final matchingCards = _cardConfigs.where((c) => c.isActive && c.smMappings.containsKey(sm.code)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt, color: Color(0xFF16A34A), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bulk Switch All Cards?',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                        Text(
                          'Switch ${matchingCards.length} active cards to ${sm.name} (${sm.code})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cards to be updated (${matchingCards.length}):',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: matchingCards.map((c) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${c.cardName} (${c.shortCode})',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This will update all shortner links in real-time.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _bulkSwitchAll(sm.code);
                        },
                        child: const Text('Switch All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<CardConfigItem> _getLiveCardsUsingSM(String smCode) {
    return _cardConfigs.where((c) => c.isActive && c.activeSm == smCode).toList();
  }

  List<CardConfigItem> _getLiveCardsUsingDSE(String dseCode) {
    return _cardConfigs.where((c) {
      if (!c.isActive || c.activeSm.isEmpty) return false;
      final mappedDse = c.smMappings[c.activeSm];
      return mappedDse == dseCode;
    }).toList();
  }

  List<CardConfigItem> _getLiveCardsUsingDSA(String dsaCode) {
    return _cardConfigs.where((c) {
      if (!c.isActive || c.activeSm.isEmpty) return false;
      final mappedDse = c.smMappings[c.activeSm];
      if (mappedDse == null || mappedDse.isEmpty) return false;
      final dseObj = _dseCodes.firstWhere(
        (d) => d.dseCode == mappedDse,
        orElse: () => DSECodeItem(dseCode: '', dseName: '', dsaCode: '', smCode: ''),
      );
      return dseObj.dsaCode == dsaCode;
    }).toList();
  }

  void _showBlockedActionDialog({
    required String title,
    required String message,
    required List<CardConfigItem> liveCards,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, color: Color(0xFFEF4444), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                        const Text(
                          'Active Live Link Protection',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                message,
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Cards currently affected:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: liveCards.map((c) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Text(
                            '${c.cardName} (${c.shortCode})',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Please switch these cards to another Sales Manager in Link Switcher (Tab 3) first before modifying.',
                style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Understood', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleDSASwitch(int index, bool val) {
    if (!val) {
      final dsaCode = _dsaCodes[index].code;
      final liveCards = _getLiveCardsUsingDSA(dsaCode);
      if (liveCards.isNotEmpty) {
        _showBlockedActionDialog(
          title: 'Cannot Deactivate DSA',
          message: 'DSA Code "$dsaCode" is currently used in live redirection.',
          liveCards: liveCards,
        );
        return;
      }
    }
    setState(() {
      _dsaCodes[index].isActive = val;
    });
    _saveSettings();
  }

  void _toggleSMSwitch(int index, bool val) {
    if (!val) {
      final smCode = _smCodes[index].code;
      final liveCards = _getLiveCardsUsingSM(smCode);
      if (liveCards.isNotEmpty) {
        _showBlockedActionDialog(
          title: 'Cannot Deactivate Manager',
          message: 'Sales Manager "${_smCodes[index].name}" ($smCode) is currently active in live redirection.',
          liveCards: liveCards,
        );
        return;
      }
    }
    setState(() {
      _smCodes[index].isActive = val;
    });
    _saveSettings();
  }

  void _toggleDSESwitch(int index, bool val) {
    if (!val) {
      final dseCode = _dseCodes[index].dseCode;
      final liveCards = _getLiveCardsUsingDSE(dseCode);
      if (liveCards.isNotEmpty) {
        _showBlockedActionDialog(
          title: 'Cannot Deactivate DSE',
          message: 'DSE Code "$dseCode" is currently active in live redirection.',
          liveCards: liveCards,
        );
        return;
      }
    }
    setState(() {
      _dseCodes[index].isActive = val;
    });
    _saveSettings();
  }

  void _toggleCardSwitch(int index, bool val) {
    setState(() {
      _cardConfigs[index].isActive = val;
    });
    _saveSettings();
  }

  Widget _buildPremiumSquareToggle({required bool isOn, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!isOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 38,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isOn ? const Color(0xFF14B8A6) : const Color(0xFFE5E7EB),
          boxShadow: [
            if (isOn)
              BoxShadow(
                color: const Color(0xFF14B8A6).withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation({
    required String title,
    required String message,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          onDelete();
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteDSA(int index) {
    final dsaCode = _dsaCodes[index].code;
    final liveCards = _getLiveCardsUsingDSA(dsaCode);
    if (liveCards.isNotEmpty) {
      _showBlockedActionDialog(
        title: 'Cannot Delete DSA',
        message: 'DSA Code "$dsaCode" is currently used in live redirection.',
        liveCards: liveCards,
      );
      return;
    }
    setState(() {
      _dsaCodes.removeAt(index);
    });
    _saveSettings();
  }

  void _deleteSM(int index) {
    final smCode = _smCodes[index].code;
    final liveCards = _getLiveCardsUsingSM(smCode);
    if (liveCards.isNotEmpty) {
      _showBlockedActionDialog(
        title: 'Cannot Delete Manager',
        message: 'Sales Manager "${_smCodes[index].name}" ($smCode) is currently active in live redirection.',
        liveCards: liveCards,
      );
      return;
    }
    setState(() {
      _smCodes.removeAt(index);
    });
    _saveSettings();
  }

  void _deleteDSE(int index) {
    final dseCode = _dseCodes[index].dseCode;
    final liveCards = _getLiveCardsUsingDSE(dseCode);
    if (liveCards.isNotEmpty) {
      _showBlockedActionDialog(
        title: 'Cannot Delete DSE',
        message: 'DSE Code "$dseCode" is currently active in live redirection.',
        liveCards: liveCards,
      );
      return;
    }
    setState(() {
      _dseCodes.removeAt(index);
    });
    _saveSettings();
  }

  void _openAddEditDSADialog({int? editIndex}) {
    final isEdit = editIndex != null;
    final codeCtrl = TextEditingController(text: isEdit ? _dsaCodes[editIndex].code : '');
    final labelCtrl = TextEditingController(text: isEdit ? _dsaCodes[editIndex].label : '');
    bool isActive = isEdit ? _dsaCodes[editIndex].isActive : true;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit DSA Code' : 'Add DSA Code',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF6B7280)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) {
                      if (errorText != null) setModalState(() => errorText = null);
                    },
                    decoration: InputDecoration(
                      labelText: 'DSA Code',
                      hintText: 'e.g. XRKD',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: labelCtrl,
                    decoration: InputDecoration(
                      labelText: 'Agency / Label Name',
                      hintText: 'e.g. Main DSA',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Active Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      _buildPremiumSquareToggle(
                        isOn: isActive,
                        onChanged: (val) => setModalState(() => isActive = val),
                      ),
                    ],
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 15, color: Color(0xFFEF4444)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              errorText!,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final code = codeCtrl.text.trim().toUpperCase();
                        final label = labelCtrl.text.trim();
                        if (code.isEmpty) {
                          setModalState(() => errorText = 'Please enter a DSA Code');
                          return;
                        }

                        final isDuplicate = _dsaCodes.asMap().entries.any((entry) {
                          if (isEdit && entry.key == editIndex) return false;
                          return entry.value.code.trim().toUpperCase() == code;
                        });

                        if (isDuplicate) {
                          setModalState(() => errorText = 'DSA Code "$code" already exists!');
                          return;
                        }

                        setState(() {
                          if (isEdit) {
                            _dsaCodes[editIndex].code = code;
                            _dsaCodes[editIndex].label = label;
                            _dsaCodes[editIndex].isActive = isActive;
                          } else {
                            _dsaCodes.add(DSACodeItem(code: code, label: label, isActive: isActive));
                          }
                        });
                        Navigator.pop(ctx);
                        _saveSettings();
                      },
                      child: Text(
                        isEdit ? 'Save Changes' : 'Add Code',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openAddEditSMDialog({int? editIndex}) {
    final isEdit = editIndex != null;
    final nameCtrl = TextEditingController(text: isEdit ? _smCodes[editIndex].name : '');
    final codeCtrl = TextEditingController(text: isEdit ? _smCodes[editIndex].code : '');
    bool isActive = isEdit ? _smCodes[editIndex].isActive : true;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Sales Manager' : 'Add Sales Manager',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF6B7280)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Manager Name',
                      hintText: 'e.g. Sales Manager A',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) {
                      if (errorText != null) setModalState(() => errorText = null);
                    },
                    decoration: InputDecoration(
                      labelText: 'SM Code',
                      hintText: 'e.g. A42859',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Active Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      _buildPremiumSquareToggle(
                        isOn: isActive,
                        onChanged: (val) => setModalState(() => isActive = val),
                      ),
                    ],
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 15, color: Color(0xFFEF4444)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              errorText!,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final code = codeCtrl.text.trim().toUpperCase();
                        if (name.isEmpty || code.isEmpty) {
                          setModalState(() => errorText = 'Please enter Manager Name and SM Code');
                          return;
                        }

                        final isDuplicate = _smCodes.asMap().entries.any((entry) {
                          if (isEdit && entry.key == editIndex) return false;
                          return entry.value.code.trim().toUpperCase() == code;
                        });

                        if (isDuplicate) {
                          setModalState(() => errorText = 'SM Code "$code" already exists!');
                          return;
                        }

                        setState(() {
                          if (isEdit) {
                            _smCodes[editIndex].name = name;
                            _smCodes[editIndex].code = code;
                            _smCodes[editIndex].isActive = isActive;
                          } else {
                            _smCodes.add(SMCodeItem(name: name, code: code, isActive: isActive));
                          }
                        });
                        Navigator.pop(ctx);
                        _saveSettings();
                      },
                      child: Text(
                        isEdit ? 'Save Changes' : 'Add Manager',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openAddEditDSEDialog({int? editIndex}) {
    final isEdit = editIndex != null;
    final codeCtrl = TextEditingController(text: isEdit ? _dseCodes[editIndex].dseCode : '');
    final nameCtrl = TextEditingController(text: isEdit ? _dseCodes[editIndex].dseName : '');
    String selectedDSA = isEdit ? _dseCodes[editIndex].dsaCode : (_dsaCodes.isNotEmpty ? _dsaCodes.first.code : '');
    String selectedSM = isEdit ? _dseCodes[editIndex].smCode : (_smCodes.isNotEmpty ? _smCodes.first.code : '');
    bool forVendor = isEdit ? _dseCodes[editIndex].forVendor : false;
    bool isActive = isEdit ? _dseCodes[editIndex].isActive : true;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit DSE Code' : 'Add DSE Code',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF6B7280)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) {
                      if (errorText != null) setModalState(() => errorText = null);
                    },
                    decoration: InputDecoration(
                      labelText: 'DSE Code',
                      hintText: 'e.g. DSE101',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'DSE Name',
                      hintText: 'e.g. Rahul Sharma',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedDSA.isNotEmpty && _dsaCodes.any((d) => d.code == selectedDSA) ? selectedDSA : null,
                    decoration: InputDecoration(
                      labelText: 'Linked DSA Code',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    hint: const Text('Select linked DSA code'),
                    items: _dsaCodes.map((d) {
                      return DropdownMenuItem<String>(
                        value: d.code,
                        child: Text('${d.code} ${d.label.isNotEmpty ? "(${d.label})" : ""}'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedDSA = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedSM.isNotEmpty && _smCodes.any((s) => s.code == selectedSM) ? selectedSM : null,
                    decoration: InputDecoration(
                      labelText: 'Linked Sales Manager (SM)',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    hint: const Text('Select linked SM code'),
                    items: _smCodes.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.code,
                        child: Text('${s.name} (${s.code})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedSM = val);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('For Vendor', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      _buildPremiumSquareToggle(
                        isOn: forVendor,
                        onChanged: (val) => setModalState(() => forVendor = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Active Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      _buildPremiumSquareToggle(
                        isOn: isActive,
                        onChanged: (val) => setModalState(() => isActive = val),
                      ),
                    ],
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 15, color: Color(0xFFEF4444)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              errorText!,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final code = codeCtrl.text.trim().toUpperCase();
                        final name = nameCtrl.text.trim();
                        if (code.isEmpty || name.isEmpty) {
                          setModalState(() => errorText = 'Please enter DSE Code and Name');
                          return;
                        }

                        final isDuplicate = _dseCodes.asMap().entries.any((entry) {
                          if (isEdit && entry.key == editIndex) return false;
                          return entry.value.dseCode.trim().toUpperCase() == code;
                        });

                        if (isDuplicate) {
                          setModalState(() => errorText = 'DSE Code "$code" already exists!');
                          return;
                        }

                        setState(() {
                          if (isEdit) {
                            _dseCodes[editIndex].dseCode = code;
                            _dseCodes[editIndex].dseName = name;
                            _dseCodes[editIndex].dsaCode = selectedDSA;
                            _dseCodes[editIndex].smCode = selectedSM;
                            _dseCodes[editIndex].forVendor = forVendor;
                            _dseCodes[editIndex].isActive = isActive;
                          } else {
                            _dseCodes.add(DSECodeItem(
                              dseCode: code,
                              dseName: name,
                              dsaCode: selectedDSA,
                              smCode: selectedSM,
                              forVendor: forVendor,
                              isActive: isActive,
                            ));
                          }
                        });
                        Navigator.pop(ctx);
                        _saveSettings();
                      },
                      child: Text(
                        isEdit ? 'Save Changes' : 'Add DSE Code',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openAddEditCardDialog({int? editIndex}) {
    final isEdit = editIndex != null;
    final nameCtrl = TextEditingController(text: isEdit ? _cardConfigs[editIndex].cardName : '');
    final shortCtrl = TextEditingController(text: isEdit ? _cardConfigs[editIndex].shortCode : '');
    final urlCtrl = TextEditingController(text: isEdit ? _cardConfigs[editIndex].baseUrl : '');
    Map<String, String> currentMappings = isEdit ? Map<String, String>.from(_cardConfigs[editIndex].smMappings) : {};
    bool isActive = isEdit ? _cardConfigs[editIndex].isActive : true;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Edit Card Template' : 'Add Card Template',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20, color: Color(0xFF6B7280)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Card Name',
                        hintText: 'e.g. HDFC Pixel',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: shortCtrl,
                      textCapitalization: TextCapitalization.none,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_-]')),
                      ],
                      onChanged: (_) {
                        if (errorText != null) setModalState(() => errorText = null);
                      },
                      decoration: InputDecoration(
                        labelText: 'Short Code',
                        hintText: 'e.g. pxl, tata',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlCtrl,
                      minLines: 4,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                        color: Color(0xFF1E293B),
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Base URL Template',
                        hintText: 'https://applyonline.bank.in/cards?DSACode={{DSA}}&LCcode={{DSE}}&SMcode={{SM}}',
                        helperText: 'Variables: {{DSA}}, {{SM}}, {{DSE}}',
                        helperStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF14B8A6)),
                        alignLabelWithHint: true,
                        isDense: false,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // SM to DSE Mapping Header
                    const Text(
                      'SM TO DSE MAPPINGS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4B5563), letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: _smCodes.isEmpty
                          ? const Text(
                              'No Sales Managers found. Please add SMs first in Settings tab.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                            )
                          : Column(
                              children: _smCodes.map((sm) {
                                final dsesForThisSM = _dseCodes.where((d) => d.smCode == sm.code && !d.forVendor && d.isActive).toList();
                                final selectedDseCode = currentMappings[sm.code];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${sm.code} (${sm.name})',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButtonFormField<String>(
                                          value: selectedDseCode != null && dsesForThisSM.any((d) => d.dseCode == selectedDseCode)
                                              ? selectedDseCode
                                              : null,
                                          isDense: true,
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            isDense: true,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                            hintText: 'Select DSE',
                                          ),
                                          items: dsesForThisSM.map((d) {
                                             final dsaObj = _dsaCodes.firstWhere(
                                               (dsa) => dsa.code == d.dsaCode,
                                               orElse: () => DSACodeItem(code: d.dsaCode, label: ''),
                                             );
                                             final dsaLabel = dsaObj.label.isNotEmpty ? dsaObj.label : d.dsaCode;
                                             final displayTitle = dsaLabel.isNotEmpty ? '${d.dseCode} ($dsaLabel)' : d.dseCode;

                                             return DropdownMenuItem<String>(
                                               value: d.dseCode,
                                               child: Text(
                                                 displayTitle,
                                                 style: const TextStyle(fontSize: 12),
                                               ),
                                             );
                                           }).toList(),
                                          onChanged: (val) {
                                            setModalState(() {
                                              if (val != null) {
                                                currentMappings[sm.code] = val;
                                              } else {
                                                currentMappings.remove(sm.code);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Active Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        _buildPremiumSquareToggle(
                          isOn: isActive,
                          onChanged: (val) => setModalState(() => isActive = val),
                        ),
                      ],
                    ),

                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, size: 15, color: Color(0xFFEF4444)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                errorText!,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final shortCode = shortCtrl.text.trim().toLowerCase();
                          final baseUrl = urlCtrl.text.trim();

                          if (name.isEmpty || shortCode.isEmpty || baseUrl.isEmpty) {
                            setModalState(() => errorText = 'Please enter Card Name, Short Code & Base URL');
                            return;
                          }

                          final isDuplicate = _cardConfigs.asMap().entries.any((entry) {
                            if (isEdit && entry.key == editIndex) return false;
                            return entry.value.shortCode.trim().toLowerCase() == shortCode;
                          });

                          if (isDuplicate) {
                            setModalState(() => errorText = 'Short Code "$shortCode" already exists!');
                            return;
                          }

                          CardConfigItem? savedCard;
                          setState(() {
                            if (isEdit) {
                              _cardConfigs[editIndex].cardName = name;
                              _cardConfigs[editIndex].shortCode = shortCode;
                              _cardConfigs[editIndex].baseUrl = baseUrl;
                              _cardConfigs[editIndex].smMappings = currentMappings;
                              _cardConfigs[editIndex].isActive = isActive;
                              savedCard = _cardConfigs[editIndex];
                            } else {
                              final newCard = CardConfigItem(
                                cardName: name,
                                shortCode: shortCode,
                                baseUrl: baseUrl,
                                smMappings: currentMappings,
                                isActive: isActive,
                              );
                              _cardConfigs.add(newCard);
                              savedCard = newCard;
                            }
                          });
                          Navigator.pop(ctx);
                          _saveSettings();

                          // AUTO-SYNC to shortner if card is live!
                          if (savedCard != null && savedCard!.isActive && savedCard!.activeSm.isNotEmpty) {
                            final freshUrl = _compileCardUrl(savedCard!, savedCard!.activeSm);
                            if (freshUrl.isNotEmpty && savedCard!.shortCode.isNotEmpty) {
                              _syncShortnerCollection(savedCard!.shortCode, freshUrl);
                            }
                          }
                        },
                        child: Text(
                          isEdit ? 'Save Changes' : 'Add Card Template',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteCard(int index) {
    setState(() {
      _cardConfigs.removeAt(index);
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F2937), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentTabIndex == 0
              ? 'Live Link Switcher'
              : _currentTabIndex == 1
                  ? 'Card Templates & Mappings'
                  : 'Master Codes Settings',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF14B8A6)),
                ),
              ),
            ),
        ],
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF14B8A6)))
          : RefreshIndicator(
              onRefresh: _loadSettings,
              color: const Color(0xFF14B8A6),
              child: _currentTabIndex == 0
                  ? _buildSwitcherTab()
                  : _currentTabIndex == 1
                      ? _buildCardsTab()
                      : _buildSettingsTab(),
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 0.8)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              _buildBottomNavItem(
                index: 0,
                icon: Icons.swap_horiz_rounded,
                label: 'Link Switcher',
              ),
              _buildBottomNavItem(
                index: 1,
                icon: Icons.credit_card_outlined,
                label: 'Card Templates',
              ),
              _buildBottomNavItem(
                index: 2,
                icon: Icons.tune_rounded,
                label: 'Master Codes',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({required int index, required IconData icon, required String label}) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTabIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TAB 1: MASTER CODES SETTINGS =================
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // 1. DSA CODES SETTING GROUP
        _buildSectionHeader(
          title: 'DSA CODES (${_dsaCodes.length})',
          onAdd: () => _openAddEditDSADialog(),
        ),
        const SizedBox(height: 8),
        _buildGroupContainer(
          children: _dsaCodes.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No DSA codes configured. Tap + to add.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    ),
                  )
                ]
              : List.generate(_dsaCodes.length, (index) {
                  final item = _dsaCodes[index];
                  final isLast = index == _dsaCodes.length - 1;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () => _openAddEditDSADialog(editIndex: index),
                        onLongPress: () => _showDeleteConfirmation(
                          title: 'Delete DSA Code',
                          message: 'Are you sure you want to delete "${item.code}"?',
                          onDelete: () => _deleteDSA(index),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      item.code,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: item.isActive ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (item.label.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          '(${item.label})',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              _buildPremiumSquareToggle(
                                isOn: item.isActive,
                                onChanged: (val) => _toggleDSASwitch(index, val),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast) const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF3F4F6)),
                    ],
                  );
                }),
        ),

        const SizedBox(height: 24),

        // 2. SALES MANAGERS (SM CODES) SETTING GROUP
        _buildSectionHeader(
          title: 'SALES MANAGERS (${_smCodes.length})',
          onAdd: () => _openAddEditSMDialog(),
        ),
        const SizedBox(height: 8),
        _buildGroupContainer(
          children: _smCodes.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No Sales Managers configured. Tap + to add.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    ),
                  )
                ]
              : List.generate(_smCodes.length, (index) {
                  final item = _smCodes[index];
                  final isLast = index == _smCodes.length - 1;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () => _openAddEditSMDialog(editIndex: index),
                        onLongPress: () => _showDeleteConfirmation(
                          title: 'Delete Sales Manager',
                          message: 'Are you sure you want to delete "${item.name}" (${item.code})?',
                          onDelete: () => _deleteSM(index),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      item.code,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: item.isActive ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (item.name.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          '(${item.name})',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFF6B7280),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              _buildPremiumSquareToggle(
                                isOn: item.isActive,
                                onChanged: (val) => _toggleSMSwitch(index, val),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast) const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF3F4F6)),
                    ],
                  );
                }),
        ),

        const SizedBox(height: 24),

        // 3. DSE CODES SETTING GROUP WITH GROUPING SELECTOR
        _buildDSEHeaderWithGrouping(),
        const SizedBox(height: 8),
        _buildDSEGroupedContent(),
      ],
    );
  }

  // ================= TAB 2: CARDS & TEMPLATES =================
  Widget _buildCardsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        _buildSectionHeader(
          title: 'CARD TEMPLATES (${_cardConfigs.length})',
          onAdd: () => _openAddEditCardDialog(),
        ),
        const SizedBox(height: 8),
        if (_cardConfigs.isEmpty)
          _buildGroupContainer(
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No card templates configured yet. Tap + to add.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
              ),
            ],
          )
        else
          ...List.generate(_cardConfigs.length, (index) {
            final card = _cardConfigs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: InkWell(
                onTap: () => _openAddEditCardDialog(editIndex: index),
                onLongPress: () => _showDeleteConfirmation(
                  title: 'Delete Card Template',
                  message: 'Are you sure you want to delete "${card.cardName}" (${card.shortCode})?',
                  onDelete: () => _deleteCard(index),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  card.cardName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: card.isActive ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E7FF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    card.shortCode,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildPremiumSquareToggle(
                            isOn: card.isActive,
                            onChanged: (val) => _toggleCardSwitch(index, val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // URL Template Full Display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          card.baseUrl,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Color(0xFF334155),
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // SM Mappings list
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: card.smMappings.entries.map((entry) {
                          final smCode = entry.key;
                          final dseCode = entry.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            child: Text(
                              '$smCode ➔ $dseCode',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  // ================= TAB 3: LIVE LINK SWITCHER =================
  Widget _buildSwitcherTab() {
    final activeSMs = _smCodes.where((s) => s.isActive).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // 1. BULK SWITCH BAR (COLLAPSIBLE)
        if (activeSMs.isNotEmpty && _cardConfigs.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isBulkSwitchExpanded = !_isBulkSwitchExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(9),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.bolt, size: 16, color: Color(0xFF16A34A)),
                            SizedBox(width: 6),
                            Text(
                              'QUICK BULK SWITCH (ALL CARDS)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              child: Text(
                                '${activeSMs.length} Managers',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              _isBulkSwitchExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: const Color(0xFF15803D),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isBulkSwitchExpanded) ...[
                  const Divider(height: 1, color: Color(0xFFBBF7D0)),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: activeSMs.map((sm) {
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => _showBulkSwitchConfirmation(sm: sm),
                          icon: const Icon(Icons.swap_horiz, size: 14, color: Colors.white),
                          label: Text(
                            'Switch All ➔ ${sm.code} (${sm.name})',
                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        _buildSectionHeader(
          title: 'ACTIVE CARDS & SHORT LINKS (${_cardConfigs.length})',
          onAdd: () => _openAddEditCardDialog(),
        ),
        const SizedBox(height: 8),
        if (_cardConfigs.isEmpty)
          _buildGroupContainer(
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No card templates found. Configure cards in Tab 2 first.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
              ),
            ],
          )
        else
          ...List.generate(_cardConfigs.length, (index) {
            final card = _cardConfigs[index];
            final currentSM = card.activeSm;
            final liveCompiledUrl = currentSM.isNotEmpty ? _compileCardUrl(card, currentSM) : '';
            final isUrlExpanded = _expandedCardUrls.contains(card.shortCode);
            final currentDse = currentSM.isNotEmpty ? (card.smMappings[currentSM] ?? '') : '';

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header: Name + Slug badge + Live status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            card.cardName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E7FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              card.shortCode,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                            ),
                          ),
                        ],
                      ),
                      if (currentSM.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.circle, size: 6, color: Color(0xFF16A34A)),
                              const SizedBox(width: 4),
                              Text(
                                'Live: $currentSM${currentDse.isNotEmpty ? " • $currentDse" : ""}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Select SM Buttons
                  const Text(
                    'Active Sales Manager:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: activeSMs.map((sm) {
                      final mappedDse = card.smMappings[sm.code] ?? '';
                      final isDseMapped = mappedDse.isNotEmpty;
                      final dseObj = isDseMapped
                          ? _dseCodes.firstWhere(
                              (d) => d.dseCode == mappedDse,
                              orElse: () => DSECodeItem(dseCode: '', dseName: '', dsaCode: '', smCode: ''),
                            )
                          : null;
                      final isDseActive = isDseMapped && (dseObj?.isActive == true) && (dseObj?.forVendor != true);
                      final isDsaActive = isDseActive && _dsaCodes.any((d) => d.code == dseObj!.dsaCode && d.isActive);
                      final isSmSelectable = isDseActive && isDsaActive;
                      final isSelected = card.activeSm == sm.code;

                      String displayDseTag = mappedDse;
                      if (!isDseMapped) {
                        displayDseTag = '⚠️ Not Mapped';
                      } else if (!isDseActive) {
                        displayDseTag = '$mappedDse (⚠️ Inactive)';
                      } else if (!isDsaActive) {
                        displayDseTag = '$mappedDse (⚠️ DSA Inactive)';
                      }

                      return GestureDetector(
                        onTap: () {
                          if (!isSmSelectable) {
                            String reason = 'Cannot switch: ';
                            if (!isDseMapped) {
                              reason += 'No DSE is mapped for ${sm.name} in Card Templates.';
                            } else if (!isDseActive) {
                              reason += 'Mapped DSE ($mappedDse) is currently Inactive.';
                            } else if (!isDsaActive) {
                              reason += 'Linked DSA (${dseObj?.dsaCode}) is currently Inactive.';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(reason),
                                backgroundColor: const Color(0xFFE11D48),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          if (isSelected) return;
                          _showSwitchConfirmation(
                            card: card,
                            sm: sm,
                            mappedDse: mappedDse,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: !isSmSelectable
                                ? const Color(0xFFF3F4F6)
                                : isSelected
                                    ? const Color(0xFFF0FDF4)
                                    : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: !isSmSelectable
                                  ? const Color(0xFFE5E7EB)
                                  : isSelected
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.3 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                Container(
                                  padding: const EdgeInsets.all(1.5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF16A34A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                                ),
                                const SizedBox(width: 5),
                              ],
                              Text(
                                '${sm.name.isNotEmpty ? sm.name : sm.code} • $displayDseTag',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: !isSmSelectable
                                      ? const Color(0xFF9CA3AF)
                                      : isSelected
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Collapsible Target URL Section
                  if (liveCompiledUrl.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isUrlExpanded) {
                                  _expandedCardUrls.remove(card.shortCode);
                                } else {
                                  _expandedCardUrls.add(card.shortCode);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.link_rounded, size: 14, color: Color(0xFF0284C7)),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'Live Redirect URL',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: liveCompiledUrl));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Live URL copied!'),
                                              duration: Duration(seconds: 1),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFCBD5E1)),
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.copy, size: 11, color: Color(0xFF0284C7)),
                                              SizedBox(width: 3),
                                              Text('Copy', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        isUrlExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isUrlExpanded) ...[
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                liveCompiledUrl,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF334155),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildDSEHeaderWithGrouping() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'DSE CODES (${_dseCodes.length})',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  _buildGroupFilterPill('SM', 'By SM'),
                  _buildGroupFilterPill('DSA', 'By DSA'),
                  _buildGroupFilterPill('ALL', 'All'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _openAddEditDSEDialog(),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, size: 15, color: Color(0xFF374151)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupFilterPill(String key, String label) {
    final isSelected = _dseGroupBy == key;
    return GestureDetector(
      onTap: () => setState(() => _dseGroupBy = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildDSEGroupedContent() {
    if (_dseCodes.isEmpty) {
      return _buildGroupContainer(
        children: const [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No DSE codes configured. Tap + to add.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      );
    }

    if (_dseGroupBy == 'SM') {
      final Map<String, List<int>> smMap = {};
      for (int i = 0; i < _dseCodes.length; i++) {
        final sm = _dseCodes[i].smCode.isEmpty ? 'Unassigned' : _dseCodes[i].smCode;
        smMap.putIfAbsent(sm, () => []).add(i);
      }

      final sortedKeys = smMap.keys.toList()..sort();

      return Column(
        children: sortedKeys.map((smCode) {
          final indices = smMap[smCode]!;
          indices.sort((a, b) {
            final itemA = _dseCodes[a];
            final itemB = _dseCodes[b];
            final dsaComp = itemA.dsaCode.compareTo(itemB.dsaCode);
            if (dsaComp != 0) return dsaComp;
            return itemA.dseCode.compareTo(itemB.dseCode);
          });

          final smObj = _smCodes.firstWhere((s) => s.code == smCode, orElse: () => SMCodeItem(name: smCode, code: smCode));

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                    border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined, size: 14, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 6),
                          Text(
                            smObj.name.isNotEmpty ? '${smObj.name} ($smCode)' : 'SM: $smCode',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${indices.length} DSE',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                        ),
                      ),
                    ],
                  ),
                ),
                ...List.generate(indices.length, (idx) {
                  final globalIndex = indices[idx];
                  final isLast = idx == indices.length - 1;
                  return _buildDSERow(globalIndex, isLast, showSMTag: false, showDSATag: true);
                }),
              ],
            ),
          );
        }).toList(),
      );
    } else if (_dseGroupBy == 'DSA') {
      final Map<String, List<int>> dsaMap = {};
      for (int i = 0; i < _dseCodes.length; i++) {
        final dsa = _dseCodes[i].dsaCode.isEmpty ? 'Unassigned' : _dseCodes[i].dsaCode;
        dsaMap.putIfAbsent(dsa, () => []).add(i);
      }

      final sortedKeys = dsaMap.keys.toList()..sort();

      return Column(
        children: sortedKeys.map((dsaCode) {
          final indices = dsaMap[dsaCode]!;
          indices.sort((a, b) {
            final itemA = _dseCodes[a];
            final itemB = _dseCodes[b];
            final smComp = itemA.smCode.compareTo(itemB.smCode);
            if (smComp != 0) return smComp;
            return itemA.dseCode.compareTo(itemB.dseCode);
          });

          final dsaObj = _dsaCodes.firstWhere((d) => d.code == dsaCode, orElse: () => DSACodeItem(code: dsaCode, label: ''));

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                    border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.domain, size: 14, color: Color(0xFF0284C7)),
                          const SizedBox(width: 6),
                          Text(
                            dsaObj.label.isNotEmpty ? '$dsaCode (${dsaObj.label})' : 'DSA: $dsaCode',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${indices.length} DSE',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                        ),
                      ),
                    ],
                  ),
                ),
                ...List.generate(indices.length, (idx) {
                  final globalIndex = indices[idx];
                  final isLast = idx == indices.length - 1;
                  return _buildDSERow(globalIndex, isLast, showSMTag: true, showDSATag: false);
                }),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      final sortedIndices = List.generate(_dseCodes.length, (i) => i);
      sortedIndices.sort((a, b) {
        final itemA = _dseCodes[a];
        final itemB = _dseCodes[b];
        final dsaComp = itemA.dsaCode.compareTo(itemB.dsaCode);
        if (dsaComp != 0) return dsaComp;
        final smComp = itemA.smCode.compareTo(itemB.smCode);
        if (smComp != 0) return smComp;
        return itemA.dseCode.compareTo(itemB.dseCode);
      });

      return _buildGroupContainer(
        children: List.generate(sortedIndices.length, (index) {
          final globalIndex = sortedIndices[index];
          final isLast = index == sortedIndices.length - 1;
          return _buildDSERow(globalIndex, isLast, showSMTag: true, showDSATag: true);
        }),
      );
    }
  }

  Widget _buildDSERow(int index, bool isLast, {required bool showSMTag, required bool showDSATag}) {
    final item = _dseCodes[index];
    return Column(
      children: [
        InkWell(
          onTap: () => _openAddEditDSEDialog(editIndex: index),
          onLongPress: () => _showDeleteConfirmation(
            title: 'Delete DSE Code',
            message: 'Are you sure you want to delete "${item.dseName}" (${item.dseCode})?',
            onDelete: () => _deleteDSE(index),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.dseCode,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: item.isActive ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (item.dseName.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '(${item.dseName})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF6B7280),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (item.forVendor) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: const Text(
                                'Vendor',
                                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          if (showDSATag && item.dsaCode.isNotEmpty)
                            Text(
                              'DSA: ${item.dsaCode}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
                            ),
                          if (showSMTag && item.smCode.isNotEmpty)
                            Text(
                              '${showDSATag && item.dsaCode.isNotEmpty ? "• " : ""}SM: ${item.smCode}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildPremiumSquareToggle(
                  isOn: item.isActive,
                  onChanged: (val) => _toggleDSESwitch(index, val),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF3F4F6)),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD1D5DB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 15, color: Color(0xFF374151)),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
