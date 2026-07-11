class PhilosophyEntry {
  final String text;
  final String author;
  final String school;
  const PhilosophyEntry(this.text, this.author, this.school);
}

class PhilosophySchool {
  final String name;
  final String origin;
  final String summary;
  final List<String> coreIdeas;
  const PhilosophySchool({
    required this.name,
    required this.origin,
    required this.summary,
    required this.coreIdeas,
  });
}

const philosophySchools = <PhilosophySchool>[
  PhilosophySchool(
    name: 'Stoicism',
    origin: 'Ancient Greece & Rome, ~300 BCE',
    summary:
        'A practical philosophy teaching that virtue is the only true good, that we should focus on what we control, and that external events are neutral — only our judgments about them cause suffering.',
    coreIdeas: [
      'Dichotomy of control: separate what you can from what you cannot influence.',
      'Virtue (wisdom, courage, justice, temperance) is sufficient for a flourishing life.',
      'Emotions follow from beliefs — examine the beliefs to change the feeling.',
      'Memento mori: remembering death sharpens what matters today.',
      'Amor fati: love what happens, treat each event as practice.',
    ],
  ),
  PhilosophySchool(
    name: 'Vedanta',
    origin: 'India, ~800 BCE onwards (Upanishads)',
    summary:
        'A school of Hindu philosophy concerned with the nature of reality (Brahman), the self (Atman), and their ultimate identity. Liberation (moksha) comes from direct knowledge of this unity.',
    coreIdeas: [
      'Brahman is the one underlying reality — formless, infinite, conscious.',
      'Atman (your inner self) is identical to Brahman: "Tat tvam asi" (Thou art that).',
      'Maya: the world as perceived is real but conditional, not ultimate.',
      'Liberation (moksha) is realization of this oneness, not an attainment.',
      'Four paths: knowledge (jnana), devotion (bhakti), action (karma), meditation (raja).',
    ],
  ),
  PhilosophySchool(
    name: 'Buddhism',
    origin: 'India, ~500 BCE (Siddhartha Gautama)',
    summary:
        'A path to ending suffering through understanding its causes and practicing the way that leads to its cessation.',
    coreIdeas: [
      'Four Noble Truths: suffering exists, has a cause (craving), can end, and there is a path.',
      'Noble Eightfold Path: right view, intention, speech, action, livelihood, effort, mindfulness, concentration.',
      'Three marks: impermanence (anicca), suffering (dukkha), non-self (anatta).',
      'Dependent origination: nothing arises independently — everything is interconnected.',
      'Compassion (karuna) and loving-kindness (metta) are essential alongside wisdom.',
    ],
  ),
  PhilosophySchool(
    name: 'Existentialism',
    origin: 'Europe, 19th–20th century',
    summary:
        'A 20th-century philosophy emphasizing individual freedom, responsibility, and the search for meaning in an indifferent universe. Existence precedes essence.',
    coreIdeas: [
      'Existence precedes essence: you create meaning through choices.',
      'Radical freedom comes with radical responsibility — and existential anxiety.',
      'Bad faith: lying to yourself about your freedom (Sartre).',
      'Authenticity: living in honest alignment with your values.',
      'The Absurd: the gap between our hunger for meaning and the universe\'s silence (Camus).',
    ],
  ),
  PhilosophySchool(
    name: 'Advaita',
    origin: 'India, Adi Shankaracharya (~8th century CE)',
    summary:
        'A non-dualistic strand of Vedanta. Reality is one (advaita = "not-two"). The apparent multiplicity is a superimposition on the one Self.',
    coreIdeas: [
      'Only Brahman is real; the world as separate from it is appearance.',
      'The individual self (jiva) is Brahman misidentified with body and mind.',
      'Discrimination (viveka) between the real and the unreal is the practice.',
      'Self-inquiry: ask "who am I?" and follow it past every identity.',
      'Liberation is the direct recognition that you were never bound.',
    ],
  ),
];

const philosophyQuotes = <PhilosophyEntry>[
  PhilosophyEntry('You have power over your mind — not outside events. Realize this, and you will find strength.', 'Marcus Aurelius', 'Stoicism'),
  PhilosophyEntry('Man is not worried by real problems so much as by his imagined anxieties about real problems.', 'Epictetus', 'Stoicism'),
  PhilosophyEntry('We suffer more often in imagination than in reality.', 'Seneca', 'Stoicism'),
  PhilosophyEntry('Waste no more time arguing what a good man should be. Be one.', 'Marcus Aurelius', 'Stoicism'),
  PhilosophyEntry('It is not what happens to you, but how you react to it that matters.', 'Epictetus', 'Stoicism'),
  PhilosophyEntry('You are not the body, you are not the mind. You are the witness of both.', 'Ramana Maharshi', 'Advaita'),
  PhilosophyEntry('Tat tvam asi — That thou art.', 'Chandogya Upanishad', 'Vedanta'),
  PhilosophyEntry('The mind is restless, but it can be controlled by practice and detachment.', 'Bhagavad Gita', 'Vedanta'),
  PhilosophyEntry('You have the right to perform your actions, but not to the fruits of your actions.', 'Bhagavad Gita 2.47', 'Vedanta'),
  PhilosophyEntry('Just be still and know — that is the whole teaching.', 'Nisargadatta Maharaj', 'Advaita'),
  PhilosophyEntry('All that we are is the result of what we have thought.', 'The Buddha (Dhammapada)', 'Buddhism'),
  PhilosophyEntry('In the end only three things matter: how much you loved, how gently you lived, how gracefully you let go.', 'Buddhist saying', 'Buddhism'),
  PhilosophyEntry('Attachment is the root of suffering.', 'The Buddha', 'Buddhism'),
  PhilosophyEntry('You yourself, as much as anybody in the entire universe, deserve your love and affection.', 'The Buddha', 'Buddhism'),
  PhilosophyEntry('Peace comes from within. Do not seek it without.', 'The Buddha', 'Buddhism'),
  PhilosophyEntry('Man is condemned to be free; because once thrown into the world, he is responsible for everything he does.', 'Jean-Paul Sartre', 'Existentialism'),
  PhilosophyEntry('One must imagine Sisyphus happy.', 'Albert Camus', 'Existentialism'),
  PhilosophyEntry('He who has a why to live for can bear almost any how.', 'Friedrich Nietzsche', 'Existentialism'),
  PhilosophyEntry('Life can only be understood backwards; but it must be lived forwards.', 'Søren Kierkegaard', 'Existentialism'),
];
