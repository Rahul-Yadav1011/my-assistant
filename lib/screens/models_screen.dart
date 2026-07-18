import 'package:flutter/material.dart';

import '../data/model_catalog.dart';
import '../services/model_manager.dart';
import '../services/settings_service.dart';
import '../theme.dart';
import '../widgets/app_drawer.dart';

class ModelsScreen extends StatefulWidget {
  const ModelsScreen({super.key});
  @override
  State<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  EngineChoice _engine = EngineChoice.groq;
  String? _activeModelId;
  bool _loaded = false;
  bool _advancedOpen = false;
  final _customUrlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _engine = await SettingsService.instance.getEngine();
    _activeModelId = await SettingsService.instance.getActiveModelId();
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _customUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _setEngine(EngineChoice e) async {
    await SettingsService.instance.setEngine(e);
    setState(() => _engine = e);
  }

  Future<void> _setActive(String modelId) async {
    await SettingsService.instance.setActiveModelId(modelId);
    // Choosing an offline model implies the user wants offline mode.
    await SettingsService.instance.setEngine(EngineChoice.onDevice);
    setState(() {
      _activeModelId = modelId;
      _engine = EngineChoice.onDevice;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offline model set as active. Engine switched to On-device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      drawer: const AppDrawer(currentIndex: 2),
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: MitraTheme.headerGradient)),
        title: const Text('AI Models'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _engineCard(),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('Offline models', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: MitraTheme.cyan.withOpacity(0.18), borderRadius: BorderRadius.circular(6)),
                child: const Text('runs without internet', style: TextStyle(fontSize: 11, color: MitraTheme.cyan)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Download a model once, then chat fully offline. Bigger models are smarter but need a newer phone.',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
          ),
          const SizedBox(height: 8),
          ...ModelCatalog.tiers.expand((tier) {
            final tierModels = ModelCatalog.byTier(tier.id);
            return [
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 18, 2, 2),
                child: Text(tier.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: MitraTheme.cyan)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
                child: Text(tier.subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
              ),
              ...tierModels.map((m) => _ModelCard(
                    model: m,
                    isActive: _activeModelId == m.id,
                    onSetActive: () => _setActive(m.id),
                  )),
            ];
          }),
          const SizedBox(height: 16),
          _advancedSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _engineCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Which AI answers you?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Switch anytime. Your choice is remembered.',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
            const SizedBox(height: 14),
            _engineOption(
              choice: EngineChoice.groq,
              icon: Icons.cloud_outlined,
              title: 'Groq (online)',
              subtitle: 'Fast, smartest answers. Needs internet + free API key.',
            ),
            const SizedBox(height: 10),
            _engineOption(
              choice: EngineChoice.onDevice,
              icon: Icons.smartphone,
              title: 'On-device (offline)',
              subtitle: 'Private, works with no internet. Needs a downloaded model.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _engineOption({
    required EngineChoice choice,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _engine == choice;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _setEngine(choice),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? MitraTheme.purple : Colors.white12,
            width: selected ? 2 : 1,
          ),
          color: selected ? MitraTheme.purple.withOpacity(0.10) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? MitraTheme.purple : Colors.white54),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? MitraTheme.purple : null)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6), height: 1.3)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: MitraTheme.purple, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _advancedSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.tune, color: Colors.white54),
            title: const Text('Advanced: custom model URL'),
            subtitle: const Text('Power users — paste a direct GGUF link'),
            trailing: Icon(_advancedOpen ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _advancedOpen = !_advancedOpen),
          ),
          if (_advancedOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _customUrlCtrl,
                    decoration: const InputDecoration(
                      hintText: 'https://huggingface.co/.../model.gguf',
                      helperText: 'Must be a small (1–4B) instruct model in GGUF format.',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Custom model download arrives in the next update.')),
                        );
                      },
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final OnDeviceModel model;
  final bool isActive;
  final VoidCallback onSetActive;
  const _ModelCard({required this.model, required this.isActive, required this.onSetActive});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(model.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (model.recommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: MitraTheme.purple.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                          child: const Text('Recommended', style: TextStyle(fontSize: 10, color: MitraTheme.purple, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isActive)
                  const Icon(Icons.check_circle, color: MitraTheme.cyan, size: 20),
              ],
            ),
            const SizedBox(height: 2),
            Text('by ${model.publisher}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
            const SizedBox(height: 8),
            Text(model.description, style: TextStyle(fontSize: 13, height: 1.4, color: Colors.white.withOpacity(0.75))),
            const SizedBox(height: 12),
            Row(
              children: [
                _chip(Icons.download_outlined, model.sizeLabel),
                const SizedBox(width: 8),
                _chip(Icons.memory, model.ramLabel),
                const SizedBox(width: 8),
                _chip(Icons.speed, model.speedLabel),
              ],
            ),
            const SizedBox(height: 14),
            _actionArea(context),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white54),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _actionArea(BuildContext context) {
    final notifier = ModelManager.instance.stateOf(model.id);
    return ValueListenableBuilder<ModelState>(
      valueListenable: notifier,
      builder: (_, state, __) {
        switch (state.status) {
          case DownloadStatus.notDownloaded:
            return SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download'),
                onPressed: () => ModelManager.instance.download(model),
              ),
            );
          case DownloadStatus.downloading:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Downloading ${(state.progress * 100).round()}%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => ModelManager.instance.cancelDownload(model.id),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: state.progress, minHeight: 8),
                ),
              ],
            );
          case DownloadStatus.downloaded:
            return Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: Icon(isActive ? Icons.check : Icons.play_arrow, size: 18),
                    label: Text(isActive ? 'Active' : 'Use this model'),
                    style: isActive
                        ? FilledButton.styleFrom(backgroundColor: MitraTheme.cyan.withOpacity(0.25), foregroundColor: MitraTheme.cyan)
                        : null,
                    onPressed: isActive ? null : onSetActive,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete download',
                  onPressed: () => ModelManager.instance.deleteModel(model.id),
                ),
              ],
            );
          case DownloadStatus.failed:
            return SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry download'),
                onPressed: () => ModelManager.instance.download(model),
              ),
            );
        }
      },
    );
  }
}
