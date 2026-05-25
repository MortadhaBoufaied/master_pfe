import 'package:flutter/material.dart';

import '../../components/app_background.dart';
import '../../components/ui_kit.dart';
import '../../controllers/academy_theme_controller.dart';
import '../../l10n/app_strings.dart';
import '../../models/academy_info.dart';
import '../../services/academy_service.dart';
import '../../services/content_translation_service.dart';
import '../../utils/backend_image.dart';

class AcademyInfoScreen extends StatefulWidget {
  const AcademyInfoScreen({super.key});

  @override
  State<AcademyInfoScreen> createState() => _AcademyInfoScreenState();
}

class _AcademyInfoScreenState extends State<AcademyInfoScreen> {
  final AcademyService _service = AcademyService();
  Future<AcademyInfo?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAcademyInfo();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final cs = Theme.of(context).colorScheme;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(t.tr('academy_info')),
        ),

        body: FutureBuilder<AcademyInfo?>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: cs.primary),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${t.tr('retry')}: ${snap.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _future = _service.getAcademyInfo();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(t.tr('retry')),
                      ),
                    ],
                  ),
                ),
              );
            }

            final info = snap.data;
            if (info == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        size: 48,
                        color: cs.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Academy info is not configured yet',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ask an admin to complete the Academy Info in the web admin panel.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _future = _service.getAcademyInfo();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // We NEVER translate names.
            final academyName = info.name;

            final desc = (info.description ?? '').trim();
            final addr = (info.address ?? '').trim();
            final phone = (info.phone ?? '').trim();
            final email = (info.email ?? '').trim();
            final place = [info.city, info.country]
                .where((value) => value != null && value.trim().isNotEmpty)
                .join(', ');
            final theme = AppAcademyTheme.instance.controller.theme;

            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          BackendAvatar(
                            pathOrUrl: info.logoUrl ?? theme.logoUrl,
                            radius: 26,
                            initials:
                                academyName.isNotEmpty ? academyName[0] : 'A',
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  academyName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  info.sportName?.isNotEmpty == true
                                      ? info.sportName!
                                      : 'ID: ${info.id}',
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (desc.isNotEmpty) ...[
                        Text(
                          t.tr('description'),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        FutureBuilder<String>(
                          future: ContentTranslationService.instance
                              .translateBasic(desc, locale),
                          builder: (context, s2) {
                            final text = s2.data ?? desc;
                            return Text(text);
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (addr.isNotEmpty)
                            FutureBuilder<String>(
                              future: ContentTranslationService.instance
                                  .translateBasic(addr, locale),
                              builder: (context, s3) {
                                final value = s3.data ?? addr;
                                return _chip(
                                  '${t.tr('academy_address')}: $value',
                                  Icons.place,
                                );
                              },
                            ),
                          if (phone.isNotEmpty)
                            _chip(
                              '${t.tr('academy_phone')}: $phone',
                              Icons.call,
                            ),
                          if (email.isNotEmpty) _chip(email, Icons.mail),
                          if (place.isNotEmpty) _chip(place, Icons.public),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _chip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(
          Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.92,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}


