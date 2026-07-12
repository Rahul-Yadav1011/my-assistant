class PhilosophyEntry {
  final String text;
  final String author;
  final String school;
  const PhilosophyEntry(this.text, this.author, this.school);
}

class Thinker {
  final String name;
  final String lived;
  final String school;
  final String bio;
  const Thinker(this.name, this.lived, this.school, this.bio);
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
        'A philosophy emphasizing individual freedom, responsibility, and the search for meaning in an indifferent universe. Existence precedes essence.',
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
  PhilosophySchool(
    name: 'Taoism',
    origin: 'China, ~400 BCE (Laozi, Zhuangzi)',
    summary:
        'A Chinese philosophy of living in harmony with the Tao — the natural, effortless way of the universe. Strength comes from yielding, wisdom from simplicity.',
    coreIdeas: [
      'The Tao that can be named is not the eternal Tao — reality exceeds words.',
      'Wu wei: effortless action, moving with the grain of things rather than forcing.',
      'Simplicity and humility outlast rigid ambition — water wears down rock.',
      'Opposites define each other (yin & yang); balance, not conquest, is the aim.',
      'The sage leads by not dominating and achieves by not grasping.',
    ],
  ),
  PhilosophySchool(
    name: 'Confucianism',
    origin: 'China, ~500 BCE (Confucius)',
    summary:
        'An ethical and social philosophy focused on cultivating virtue, right relationships, and harmony in society through personal character and respect.',
    coreIdeas: [
      'Ren (benevolence): cultivate genuine care for others.',
      'Li (propriety): act with the right conduct and respect in each relationship.',
      'The family and social roles are the training ground for virtue.',
      'Lead by moral example, not force — character shapes society.',
      'Lifelong learning and self-cultivation are duties, not options.',
    ],
  ),
  PhilosophySchool(
    name: 'Absurdism',
    origin: 'Europe, 20th century (Albert Camus)',
    summary:
        'The view that humans seek meaning in a universe that offers none, and that we should respond not with despair or false hope, but with rebellion, freedom, and passion for life.',
    coreIdeas: [
      'The Absurd is the clash between our search for meaning and the silent universe.',
      'Neither suicide nor blind faith resolves the Absurd — both are escapes.',
      'Revolt: live fully and consciously in spite of meaninglessness.',
      'Freedom: without preset meaning, you are free to define your own.',
      'Imagine Sisyphus happy — the struggle itself can fill a life.',
    ],
  ),
];

const thinkers = <Thinker>[
  Thinker('Marcus Aurelius', '121–180 CE', 'Stoicism',
      'Roman emperor and Stoic philosopher whose private journal, "Meditations", remains one of the most-read works on self-discipline and equanimity.'),
  Thinker('Epictetus', '~50–135 CE', 'Stoicism',
      'Born a slave, became a revered Stoic teacher. Taught that freedom comes from mastering our judgments, not our circumstances.'),
  Thinker('Seneca', '~4 BCE–65 CE', 'Stoicism',
      'Roman statesman and writer whose letters on grief, time, and anger turned Stoic theory into practical daily counsel.'),
  Thinker('Adi Shankaracharya', '~700–750 CE', 'Advaita',
      'Consolidated Advaita Vedanta, arguing that the individual self and ultimate reality are one, and that liberation is realizing this directly.'),
  Thinker('The Buddha', '~563–483 BCE', 'Buddhism',
      'Siddhartha Gautama, who taught the Four Noble Truths and the Eightfold Path as a practical route out of suffering.'),
  Thinker('Laozi', '~6th century BCE', 'Taoism',
      'Semi-legendary author of the Tao Te Ching, foundational text of Taoism, teaching harmony with the natural way and the power of yielding.'),
  Thinker('Confucius', '551–479 BCE', 'Confucianism',
      'Chinese teacher whose emphasis on virtue, respect, and right relationships shaped East Asian ethics for over two millennia.'),
  Thinker('Jean-Paul Sartre', '1905–1980', 'Existentialism',
      'French existentialist who argued that we are "condemned to be free" and wholly responsible for the meaning we create.'),
  Thinker('Albert Camus', '1913–1960', 'Absurdism',
      'French-Algerian writer who framed the Absurd and urged us to live with revolt, freedom, and passion despite the lack of inherent meaning.'),
  Thinker('Friedrich Nietzsche', '1844–1900', 'Existentialism',
      'German philosopher who probed nihilism, the "will to power", and self-overcoming, urging us to create our own values.'),
];

const philosophyQuotes = <PhilosophyEntry>[
  PhilosophyEntry('You have power over your mind — not outside events. Realize this, and you will find strength.', 'Marcus Aurelius', 'Stoicism'),
  PhilosophyEntry('Man is not worried by real problems so much as by his imagined anxieties about real problems.', 'Epictetus', 'Stoicism'),
  PhilosophyEntry('We suffer more often in imagination than in reality.', 'Seneca', 'Stoicism'),
  PhilosophyEntry('Waste no more time arguing what a good man should be. Be one.', 'Marcus Aurelius', 'Stoicism'),
  PhilosophyEntry('It is not what happens to you, but how you react to it that matters.', 'Epictetus', 'Stoicism'),
  PhilosophyEntry('The happiness of your life depends upon the quality of your thoughts.', 'Marcus Aurelius', 'Stoicism'),
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
  PhilosophyEntry('One must imagine Sisyphus happy.', 'Albert Camus', 'Absurdism'),
  PhilosophyEntry('He who has a why to live for can bear almost any how.', 'Friedrich Nietzsche', 'Existentialism'),
  PhilosophyEntry('Life can only be understood backwards; but it must be lived forwards.', 'Søren Kierkegaard', 'Existentialism'),
  PhilosophyEntry('The journey of a thousand miles begins with a single step.', 'Laozi', 'Taoism'),
  PhilosophyEntry('Nature does not hurry, yet everything is accomplished.', 'Laozi', 'Taoism'),
  PhilosophyEntry('When I let go of what I am, I become what I might be.', 'Laozi', 'Taoism'),
  PhilosophyEntry('The flame that burns twice as bright burns half as long.', 'Laozi', 'Taoism'),
  PhilosophyEntry('It does not matter how slowly you go as long as you do not stop.', 'Confucius', 'Confucianism'),
  PhilosophyEntry('The man who moves a mountain begins by carrying away small stones.', 'Confucius', 'Confucianism'),
  PhilosophyEntry('Our greatest glory is not in never falling, but in rising every time we fall.', 'Confucius', 'Confucianism'),
  PhilosophyEntry('When it is obvious that the goals cannot be reached, adjust the action steps.', 'Confucius', 'Confucianism'),
  PhilosophyEntry('In the midst of winter, I found there was, within me, an invincible summer.', 'Albert Camus', 'Absurdism'),
  PhilosophyEntry('You will never be happy if you continue to search for what happiness consists of.', 'Albert Camus', 'Absurdism'),
  PhilosophyEntry('That which does not kill us makes us stronger.', 'Friedrich Nietzsche', 'Existentialism'),
  PhilosophyEntry('The wound is the place where the Light enters you.', 'Rumi', 'Vedanta'),
];
