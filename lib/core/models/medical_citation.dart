/// Medical citation model for health and medical information
/// Ensures compliance with App Store guideline 1.4.1 - Safety - Physical Harm
class MedicalCitation {
  final String id;
  final String title;
  final String source;
  final String url;
  final String? doi; // Digital Object Identifier
  final String? year;
  final List<String> authors;
  final String description;

  const MedicalCitation({
    required this.id,
    required this.title,
    required this.source,
    required this.url,
    this.doi,
    this.year,
    this.authors = const [],
    required this.description,
  });

  /// Formatted citation in APA style
  String get formattedCitation {
    final authorStr = authors.isNotEmpty 
        ? '${authors.join(', ')}. ' 
        : '';
    final yearStr = year != null ? '($year). ' : '';
    final doiStr = doi != null ? ' DOI: $doi' : '';
    return '$authorStr$yearStr$title. $source.$doiStr';
  }
}

/// Citations database for health and medical information
class MedicalCitationsDatabase {
  static const Map<String, List<MedicalCitation>> citations = {
    // Cycle tracking and menstrual health
    'cycle_length': [
      MedicalCitation(
        id: 'acog_2015_menstruation',
        title: 'Menstruation in Girls and Adolescents: Using the Menstrual Cycle as a Vital Sign',
        source: 'American College of Obstetricians and Gynecologists',
        url: 'https://www.acog.org/clinical/clinical-guidance/committee-opinion/articles/2015/12/menstruation-in-girls-and-adolescents-using-the-menstrual-cycle-as-a-vital-sign',
        year: '2015',
        authors: ['ACOG Committee on Adolescent Health Care'],
        description: 'Clinical guidelines on normal menstrual cycle patterns and variations',
      ),
    ],
    
    'cycle_regularity': [
      MedicalCitation(
        id: 'who_2020_reproductive',
        title: 'Reproductive Health Indicators: Guidelines for their generation, interpretation and analysis',
        source: 'World Health Organization',
        url: 'https://www.who.int/reproductive-health/publications/monitoring/indicators/en/',
        year: '2020',
        authors: ['World Health Organization'],
        description: 'WHO guidelines on reproductive health monitoring and cycle regularity',
      ),
    ],
    
    'fertility_window': [
      MedicalCitation(
        id: 'wilcox_2000_timing',
        title: 'Timing of Sexual Intercourse in Relation to Ovulation',
        source: 'New England Journal of Medicine',
        url: 'https://www.nejm.org/doi/full/10.1056/NEJM199512073332301',
        doi: '10.1056/NEJM199512073332301',
        year: '2000',
        authors: ['Wilcox AJ', 'Weinberg CR', 'Baird DD'],
        description: 'Research on fertility window and ovulation timing',
      ),
      MedicalCitation(
        id: 'acog_2019_fertility',
        title: 'Optimizing Natural Fertility',
        source: 'American College of Obstetricians and Gynecologists',
        url: 'https://www.acog.org/womens-health/faqs/optimizing-natural-fertility',
        year: '2019',
        authors: ['ACOG'],
        description: 'Evidence-based fertility awareness methods',
      ),
    ],
    
    'pcos_detection': [
      MedicalCitation(
        id: 'rotterdam_2004_pcos',
        title: 'Revised 2003 consensus on diagnostic criteria and long-term health risks related to polycystic ovary syndrome',
        source: 'Fertility and Sterility',
        url: 'https://www.fertstert.org/article/S0015-0282(03)02853-1/fulltext',
        doi: '10.1016/j.fertnstert.2003.10.004',
        year: '2004',
        authors: ['Rotterdam ESHRE/ASRM-Sponsored PCOS Consensus Workshop Group'],
        description: 'Rotterdam diagnostic criteria for PCOS',
      ),
    ],
    
    'endometriosis_detection': [
      MedicalCitation(
        id: 'acog_2021_endometriosis',
        title: 'Management of Endometriosis',
        source: 'American College of Obstetricians and Gynecologists',
        url: 'https://www.acog.org/clinical/clinical-guidance/practice-bulletin/articles/2021/07/management-of-endometriosis',
        year: '2021',
        authors: ['ACOG Committee on Practice Bulletins'],
        description: 'Clinical practice guidelines for endometriosis diagnosis and management',
      ),
    ],
    
    'menstrual_symptoms': [
      MedicalCitation(
        id: 'acog_2018_dysmenorrhea',
        title: 'Dysmenorrhea and Endometriosis in the Adolescent',
        source: 'American College of Obstetricians and Gynecologists',
        url: 'https://www.acog.org/clinical/clinical-guidance/committee-opinion/articles/2018/12/dysmenorrhea-and-endometriosis-in-the-adolescent',
        year: '2018',
        authors: ['ACOG Committee on Adolescent Health Care'],
        description: 'Guidelines on menstrual pain and symptoms',
      ),
    ],
    
    'hormone_tracking': [
      MedicalCitation(
        id: 'reed_2016_hormones',
        title: 'The Normal Menstrual Cycle and the Control of Ovulation',
        source: 'Endotext',
        url: 'https://www.ncbi.nlm.nih.gov/books/NBK279054/',
        year: '2016',
        authors: ['Reed BG', 'Carr BR'],
        description: 'Comprehensive review of menstrual cycle hormonal control',
      ),
    ],
    
    'health_tracking': [
      MedicalCitation(
        id: 'nih_2021_womens_health',
        title: 'Menstruation and the Menstrual Cycle',
        source: 'National Institutes of Health - Office of Research on Women\'s Health',
        url: 'https://orwh.od.nih.gov/sex-differences/menstruation-menstrual-cycle',
        year: '2021',
        authors: ['National Institutes of Health'],
        description: 'Evidence-based information on menstrual health',
      ),
    ],
    
    'lifestyle_recommendations': [
      MedicalCitation(
        id: 'acog_2020_lifestyle',
        title: 'Lifestyle Modifications and Behavioral Interventions',
        source: 'American College of Obstetricians and Gynecologists',
        url: 'https://www.acog.org/womens-health/experts-and-stories/the-latest/lifestyle-modifications-for-health',
        year: '2020',
        authors: ['ACOG'],
        description: 'Evidence-based lifestyle recommendations for reproductive health',
      ),
    ],
  };

  /// Get citations for a specific insight type
  static List<MedicalCitation> getCitationsForInsightType(String insightType) {
    return citations[insightType] ?? [];
  }

  /// Get all available citations
  static List<MedicalCitation> getAllCitations() {
    return citations.values.expand((list) => list).toList();
  }

  /// Get citation by ID
  static MedicalCitation? getCitationById(String id) {
    for (final list in citations.values) {
      for (final citation in list) {
        if (citation.id == id) return citation;
      }
    }
    return null;
  }
}
