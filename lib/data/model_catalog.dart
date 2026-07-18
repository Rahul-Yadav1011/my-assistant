/// Catalog of on-device models the user can download and run offline.
///
/// Every entry is a real, phone-compatible small instruct model in GGUF
/// format. Grouped by size tier so the list feels organized, not sparse.
class OnDeviceModel {
  final String id;
  final String name;
  final String publisher;
  final String description;
  final double sizeGb;
  final double minRamGb;
  final String speedLabel; // Fast / Balanced / Smartest
  final String tier; // 'tiny', 'small', 'capable'
  final String downloadUrl;
  final bool recommended;

  const OnDeviceModel({
    required this.id,
    required this.name,
    required this.publisher,
    required this.description,
    required this.sizeGb,
    required this.minRamGb,
    required this.speedLabel,
    required this.tier,
    required this.downloadUrl,
    this.recommended = false,
  });

  String get sizeLabel =>
      sizeGb < 1 ? '${(sizeGb * 1000).round()} MB' : '${sizeGb.toStringAsFixed(1)} GB';
  String get ramLabel => '${minRamGb.toStringAsFixed(0)} GB RAM';
}

class ModelTier {
  final String id;
  final String title;
  final String subtitle;
  const ModelTier(this.id, this.title, this.subtitle);
}

class ModelCatalog {
  static const List<ModelTier> tiers = [
    ModelTier('tiny', 'Tiny — fastest, any phone', 'Under 1 GB. Runs on almost any device. Great for quick chat.'),
    ModelTier('small', 'Small — balanced', '1–2 GB. Better answers, still comfortable on most phones.'),
    ModelTier('capable', 'Capable — smartest offline', '2 GB+. Best quality, needs a newer phone with more RAM.'),
  ];

  static const List<OnDeviceModel> models = [
    // ---------------- TINY (< 1 GB) ----------------
    OnDeviceModel(
      id: 'gemma3-1b-it',
      name: 'Gemma 3 1B',
      publisher: 'Google',
      description: 'Small and quick. Great all-rounder for phones with limited RAM. Recommended starting point.',
      sizeGb: 0.55,
      minRamGb: 3,
      speedLabel: 'Fast',
      tier: 'tiny',
      downloadUrl: 'https://huggingface.co/google/gemma-3-1b-it-qat-q4_0-gguf/resolve/main/gemma-3-1b-it-q4_0.gguf',
      recommended: true,
    ),
    OnDeviceModel(
      id: 'llama3.2-1b-it',
      name: 'Llama 3.2 1B',
      publisher: 'Meta',
      description: 'Meta\'s compact model. Good instruction-following and general chat in a tiny footprint.',
      sizeGb: 0.81,
      minRamGb: 3,
      speedLabel: 'Fast',
      tier: 'tiny',
      downloadUrl: 'https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf',
    ),
    OnDeviceModel(
      id: 'smollm2-1.7b',
      name: 'SmolLM2 1.7B',
      publisher: 'Hugging Face',
      description: 'Punches above its weight. Trained by Hugging Face for strong performance at a small size.',
      sizeGb: 0.99,
      minRamGb: 4,
      speedLabel: 'Fast',
      tier: 'tiny',
      downloadUrl: 'https://huggingface.co/bartowski/SmolLM2-1.7B-Instruct-GGUF/resolve/main/SmolLM2-1.7B-Instruct-Q4_K_M.gguf',
    ),
    OnDeviceModel(
      id: 'qwen2.5-0.5b',
      name: 'Qwen 2.5 0.5B',
      publisher: 'Alibaba',
      description: 'Extremely light. For older or low-RAM phones where every megabyte counts.',
      sizeGb: 0.40,
      minRamGb: 2,
      speedLabel: 'Fast',
      tier: 'tiny',
      downloadUrl: 'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf',
    ),

    // ---------------- SMALL (1–2 GB) ----------------
    OnDeviceModel(
      id: 'qwen2.5-1.5b-it',
      name: 'Qwen 2.5 1.5B',
      publisher: 'Alibaba',
      description: 'Good balance of speed and quality. Strong at reasoning and multilingual chat for its size.',
      sizeGb: 1.0,
      minRamGb: 4,
      speedLabel: 'Balanced',
      tier: 'small',
      downloadUrl: 'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf',
    ),
    OnDeviceModel(
      id: 'gemma2-2b-it',
      name: 'Gemma 2 2B',
      publisher: 'Google',
      description: 'Well-rounded and reliable. A dependable step up in quality from the 1B models.',
      sizeGb: 1.6,
      minRamGb: 5,
      speedLabel: 'Balanced',
      tier: 'small',
      downloadUrl: 'https://huggingface.co/bartowski/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf',
    ),
    OnDeviceModel(
      id: 'llama3.2-3b-it',
      name: 'Llama 3.2 3B',
      publisher: 'Meta',
      description: 'Noticeably smarter chat and reasoning. A great everyday offline model if your phone can handle it.',
      sizeGb: 2.0,
      minRamGb: 6,
      speedLabel: 'Balanced',
      tier: 'small',
      downloadUrl: 'https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf',
    ),

    // ---------------- CAPABLE (2 GB+) ----------------
    OnDeviceModel(
      id: 'phi3.5-mini',
      name: 'Phi-3.5 Mini',
      publisher: 'Microsoft',
      description: 'Microsoft\'s reasoning-focused model. Excellent at logic, coding help, and structured answers.',
      sizeGb: 2.4,
      minRamGb: 6,
      speedLabel: 'Smartest',
      tier: 'capable',
      downloadUrl: 'https://huggingface.co/bartowski/Phi-3.5-mini-instruct-GGUF/resolve/main/Phi-3.5-mini-instruct-Q4_K_M.gguf',
    ),
    OnDeviceModel(
      id: 'gemma3-4b-it',
      name: 'Gemma 3 4B',
      publisher: 'Google',
      description: 'The smartest option that still fits on a phone. Best answers, but needs a newer phone and more data.',
      sizeGb: 2.5,
      minRamGb: 6,
      speedLabel: 'Smartest',
      tier: 'capable',
      downloadUrl: 'https://huggingface.co/google/gemma-3-4b-it-qat-q4_0-gguf/resolve/main/gemma-3-4b-it-q4_0.gguf',
    ),
    OnDeviceModel(
      id: 'qwen2.5-3b-it',
      name: 'Qwen 2.5 3B',
      publisher: 'Alibaba',
      description: 'Strong reasoning and multilingual ability. A capable alternative to Gemma 3 4B.',
      sizeGb: 2.1,
      minRamGb: 6,
      speedLabel: 'Smartest',
      tier: 'capable',
      downloadUrl: 'https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf',
    ),
  ];

  static List<OnDeviceModel> byTier(String tier) =>
      models.where((m) => m.tier == tier).toList(growable: false);

  static OnDeviceModel? byId(String? id) {
    if (id == null) return null;
    for (final m in models) {
      if (m.id == id) return m;
    }
    return null;
  }
}
