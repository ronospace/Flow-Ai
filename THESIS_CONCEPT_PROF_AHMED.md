# Flow-AI Thesis Concept Document

**Student**: Geoffrey Kipngetich Rono  
**Matriculation Number**: 74199495  
**Programme**: MSc Data Science (90 ECTS)  
**University**: University of Europe for Applied Sciences  
**Date**: 28 October 2025

---

## Title

**Flow-AI: Machine Learning for Cycle Prediction and Symptom Intelligence in Menstrual Health Tracking**

---

## Problem Statement

Menstrual health tracking applications serve over 200 million users globally, yet most rely on simple rule-based algorithms that assume regular 28-day cycles. Research shows these methods achieve only 60-75% prediction accuracy, leading to high user abandonment rates (over 70% within three months).

Current applications fail to address:
- **Individual Variability**: Cycles vary significantly due to stress, hormonal changes, lifestyle factors, and health conditions
- **Limited Personalization**: Existing apps cannot adapt to users' unique cycle patterns
- **Trust Deficit**: Poor predictions erode user confidence in digital health tools

While commercial menstrual tracking applications exist, there is insufficient academic research examining:
1. Comparative effectiveness of machine learning versus rule-based menstrual predictions
2. Symptom-cycle phase correlations using real-world longitudinal user data
3. User trust and acceptance of AI-driven health predictions

Flow-AI addresses this research gap by providing a platform for rigorous evaluation combining technical machine learning performance with real-world user perception analysis.

---

## Research Questions

**RQ1**: How accurately can ensemble machine learning models (Random Forest, LSTM, clustering) predict menstrual cycle phases compared to traditional rule-based methods?

**RQ2**: Which symptoms demonstrate statistically significant correlation with menstrual cycle phases based on longitudinal user tracking data?

**RQ3**: How do users perceive the usefulness, accuracy, trustworthiness, and privacy implications of AI-driven menstrual health predictions?

**RQ4**: What factors (data quantity, cycle regularity, symptom logging consistency) most influence prediction accuracy?

---

## Methodology

### Research Design
Mixed-methods approach combining quantitative machine learning evaluation with qualitative user experience research.

### Quantitative Component

**Data Collection**
- Platform: Flow-AI mobile application (Flutter-based, cross-platform iOS/Android/Web)
- Duration: 3 months
- Storage: Firebase Firestore (EU region: eur3) - GDPR compliant

**Machine Learning Pipeline**
- **Baseline Models**: Simple averaging, calendar-based prediction (28-day assumption)
- **ML Models**: Random Forest (cycle classification, symptom patterns), LSTM Networks (sequential learning with 12-cycle memory), K-means Clustering (symptom grouping)
- **Ensemble Approach**: Weighted combination of models
- **Training**: 80% training, 10% validation, 10% test with 5-fold cross-validation

**Evaluation Metrics**
- Cycle Prediction: MAE, RMSE, accuracy within ±1 day
- Classification: Precision, Recall, F1-score
- Symptom Correlation: Pearson/Spearman coefficients with significance testing
- Benchmarking: Compare against reported accuracy rates in existing literature on menstrual prediction systems, Target: >80% accuracy

### Qualitative Component

**Participants**: Subset of 50-100 active Flow-AI users (stratified sampling)

**Methods**:
- In-app surveys (n=50+): Prediction accuracy perception, trust, feature usefulness, privacy concerns
- Semi-structured interviews (n=10-15): User mental models, decision-making impact

**Analysis**: Thematic analysis using NVivo/MAXQDA, triangulation with quantitative results

---

## Dataset Identification

### Primary Dataset
- **Source**: Anonymized menstrual cycle and symptom logs from Flow-AI application users
- **Storage**: Google Firebase Firestore, EU data region (eur3)
- **Compliance**: GDPR compliant, informed consent, data minimization
- **Scale**: 50-100 active users contributing longitudinal cycle data
- **Expected Volume**: 2,000-4,000 daily tracking entries over 3 months

### Features Collected
- **Cycle Data**: Start/end dates, flow intensity (5 levels), cycle length
- **Symptoms**: 70+ tracked symptoms with severity ratings (1-10 scale)
- **Mood & Energy**: Daily mood states and energy levels
- **Lifestyle**: Sleep quality, stress levels, exercise frequency
- **Biometrics** (optional): Temperature, heart rate via wearable device integration

### Data Privacy & Security
- All personally identifiable information removed before analysis
- Explicit informed consent obtained from all participants
- Encryption: AES-256 at rest, TLS 1.3 in transit
- User rights: Data deletion, opt-out, data portability fully honored
- Data used solely for academic research purposes

### Supplementary Data
- Minimal synthetic data augmentation may be used if needed for model robustness
- Any synthetic data will be clearly documented and separated in analyses

---

## Ethical Considerations

All data will be anonymized, and explicit informed consent will be obtained from participants. Research will strictly adhere to GDPR guidelines. University IRB/ethics committee approval will be secured before formal data collection begins. Predictions are informational only, not diagnostic.

---

**Student Contact**  
Geoffrey Kipngetich Rono  
Email: geoffrey.rono@ue-germany.de  
Matriculation Number: 74199495
