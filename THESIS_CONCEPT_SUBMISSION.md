# Flow-AI: Machine Learning for Menstrual Health Prediction
## Thesis Concept Document

**Student**: Geoffrey Kipngetich Rono  
**Matriculation Number**: 74199495  
**Programme**: MSc Data Science (90 ECTS)  
**University**: University of Europe for Applied Sciences  
**Date**: 28 October 2025

---

## Title

Flow-AI: Machine Learning for Cycle Prediction and Symptom Intelligence in Menstrual Health Tracking

---

## Problem Statement

Menstrual health tracking applications serve over 200 million users globally, yet most rely on simple rule-based algorithms that assume regular 28-day cycles. Research shows these methods achieve only 60-75% prediction accuracy, leading to high user abandonment rates (over 70% within three months).

Current limitations include:
- **Individual Variability**: Cycles vary significantly due to stress, hormonal changes, lifestyle factors, and health conditions
- **Limited Personalization**: Existing apps fail to adapt to users' unique cycle patterns
- **Trust Deficit**: Poor predictions erode user confidence in digital health tools
- **Research Gap**: Limited peer-reviewed studies evaluating ML effectiveness in real-world menstrual health contexts

While commercial menstrual tracking applications exist, there is insufficient academic research examining:
1. Comparative effectiveness of machine learning versus rule-based menstrual predictions
2. Symptom-cycle phase correlations using real-world longitudinal user data
3. User trust and acceptance of AI-driven health predictions in sensitive health contexts
4. Privacy-preserving methodologies for machine learning in personal health tracking

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
This research adopts a mixed-methods approach combining quantitative machine learning evaluation with qualitative user experience research.

### Quantitative Component

**Data Source**
- Platform: Flow-AI mobile application (Flutter-based, cross-platform)
- Collection Period: 12 months
- Storage: Firebase Firestore (EU region: eur3) - GDPR compliant

**Dataset Scale**
- Target: 100 active users contributing longitudinal cycle data
- Expected: 2,000-3,000 daily tracking entries over 12 months
- Features: Cycle dates, flow intensity (5 levels), 70+ symptoms with severity ratings, mood/energy levels, lifestyle factors

**Machine Learning Pipeline**

*Data Preprocessing*
- Anonymization (remove all personally identifiable information)
- Missing data imputation (KNN, forward-fill for time series)
- Outlier detection (IQR method, physiologically plausible ranges)
- Feature engineering (rolling averages, lagged features, cycle phase encoding)

*Model Development*
- Baseline Models: Simple averaging, calendar-based prediction (28-day assumption)
- Random Forest: Cycle length classification, symptom pattern recognition
- LSTM Networks: Sequential cycle pattern learning with 12-cycle memory
- K-means Clustering: Symptom grouping and cycle pattern identification
- Ensemble Approach: Weighted combination of models

*Training Strategy*
- Temporal split: 80% training, 10% validation, 10% test
- Cross-validation: 5-fold time-series cross-validation
- Hyperparameter tuning: Grid search with validation set

**Evaluation Metrics**
- Cycle Prediction: MAE (days), RMSE, accuracy within ±1 day, ±2 days
- Classification: Precision, Recall, F1-score for phase prediction
- Symptom Correlation: Pearson/Spearman correlation coefficients with statistical significance testing
- Model Comparison: Friedman test, Wilcoxon signed-rank test for statistical validation

**Comparative Benchmarking**
- Baseline 1: Simple averaging (last 3 cycles)
- Baseline 2: Calendar method (fixed 28-day cycles)
- Commercial Apps: Published accuracy rates (Flo: approximately 72%, Clue: approximately 75%)
- Target: Greater than 80% accuracy (±1 day), demonstrating measurable improvement

### Qualitative Component

**Participants**
- Subset of 30-50 active Flow-AI users
- Stratified sampling: regular versus irregular cycles, varying engagement levels

**Data Collection Methods**

*In-App Surveys (n=50+)*
- Prediction accuracy perception (5-point Likert scale)
- Trust in AI recommendations
- Feature usefulness ratings
- Privacy concern assessment

*Semi-Structured Interviews (n=10-15)*
- User mental models of AI predictions
- Understanding of confidence scores and explanations
- Impact on health decision-making
- Privacy and data control preferences

**Analysis Approach**
- Thematic Analysis: NVivo or MAXQDA for qualitative coding
- Triangulation: Cross-validation of quantitative metrics with qualitative insights
- Mixed-methods integration: Convergent parallel design

---

## Dataset Identification

### Primary Dataset
- **Source**: Anonymized menstrual cycle and symptom logs from Flow-AI users
- **Storage**: Google Firebase Firestore, EU data region (eur3)
- **Compliance**: GDPR, informed consent, data minimization principles
- **Expected Scale**: 100 active users, 2,000-3,000 daily tracking entries over 12 months
- **Features Collected**:
  - Cycle data: Start/end dates, flow intensity, cycle length
  - Symptoms: 70+ tracked symptoms with severity ratings (1-10 scale)
  - Mood and energy: Daily states and levels
  - Lifestyle: Sleep quality, stress levels, exercise frequency
  - Biometrics (optional): Temperature, heart rate via wearable integration

### Data Privacy and Security
- **Anonymization**: All personally identifiable information removed before analysis
- **Consent**: Explicit informed consent obtained from all participants
- **Encryption**: AES-256 at rest, TLS 1.3 in transit
- **Access Control**: Role-based access with audit logging
- **User Rights**: Data deletion, opt-out, data portability honored
- **Purpose Limitation**: Data used solely for academic research

### Supplementary Data
- Minimal synthetic data augmentation may be used if needed to improve model robustness for edge cases
- Any synthetic data will be clearly documented and separated in all analyses

---

## Ethical Considerations

All health-related data will be anonymized before analysis, and explicit informed consent will be obtained from all participants. The research will strictly adhere to GDPR guidelines for sensitive data handling.

Key ethical commitments:
- **No Medical Claims**: Predictions are informational, not diagnostic
- **Transparency**: Users fully informed about AI limitations and confidence levels
- **Bias Mitigation**: Diverse user representation, fairness evaluation across demographics
- **Ethics Approval**: University IRB/ethics committee approval will be obtained before formal data collection begins
- **User Protection**: Clear disclaimers, no medical advice, informational predictions only

---

## Expected Contributions

### Technical Contributions
- Validated ensemble machine learning architecture for menstrual cycle prediction using real-world data
- Feature importance analysis identifying most predictive variables for cycle accuracy
- Statistical evidence of symptom-cycle phase correlations
- Privacy-preserving methodology for ethical health data analysis

### Scientific Contributions
- Empirical validation of machine learning effectiveness in menstrual health tracking with 100 real users
- Comparative analysis of ML versus rule-based methods with statistical significance testing
- Mixed-methods framework integrating quantitative performance and qualitative user perception
- Reproducible methodology applicable to broader FemTech machine learning research

### Practical Contributions
- Evidence-based guidelines for AI health prediction acceptance and user trust
- Design recommendations for explainable AI in sensitive health contexts
- Scalability insights for deploying ML-powered health applications
- Academic benchmarking against commercial solutions

---

## Success Criteria

**Minimum Viable Success**
- Collect data from 50+ users (1,000+ entries)
- Achieve greater than 75% prediction accuracy (±1 day) - matching or exceeding commercial apps
- Complete 30+ user surveys
- Demonstrate statistical significance in ML versus baseline comparison (p < 0.05)

**Target Success**
- Collect data from 100+ users (2,000-3,000 entries)
- Achieve greater than 80% prediction accuracy (±1 day)
- Complete 50+ surveys and 10-15 interviews
- Identify 5+ statistically significant symptom-cycle correlations
- Prepare manuscript for peer-reviewed journal submission

---

## Limitations

The following limitations are acknowledged:
- **Self-Reported Data**: Reliance on user accuracy in symptom tracking
- **Demographic Scope**: Primarily European users (generalizability considerations)
- **Sample Size**: While adequate for academic validation, smaller than commercial datasets
- **Study Duration**: 12-month timeframe may not capture long-term cycle changes

---

## Preliminary References

1. Li, K., et al. (2020). "Accuracy of menstrual cycle prediction apps." *Obstetrics & Gynecology*, 135(3), 656-663.

2. Moglia, M. L., et al. (2016). "Evaluation of smartphone menstrual cycle tracking applications." *Obstetrics & Gynecology*, 127(6), 1153-1160.

3. Bull, J. R., et al. (2019). "Real-world menstrual cycle characteristics of more than 600,000 menstrual cycles." *NPJ Digital Medicine*, 2(1), 1-8.

4. Hochreiter, S., & Schmidhuber, J. (1997). "Long short-term memory." *Neural Computation*, 9(8), 1735-1780.

---

## Document Status

This thesis concept document is submitted for supervisor review and approval. Upon approval, the following steps will be initiated:

1. Submit to university ethics committee for formal approval
2. Begin structured data collection with informed consent protocols
3. Develop machine learning models and evaluation framework
4. Conduct user surveys and interviews
5. Complete thesis manuscript and prepare for defense

---

**Student Contact**  
Geoffrey Kipngetich Rono  
Email: geoffrey.rono@ue-germany.de  
Matriculation Number: 74199495

---

*Document prepared 28 October 2025*

---

## Appendix A: Proposed Timeline

| Phase | Duration | Key Activities |
|-------|----------|----------------|
| Phase 1: Pilot | Months 1-3 | Initial user recruitment, baseline data collection, model development |
| Phase 2: Development | Months 4-6 | ML model training, hyperparameter tuning, preliminary evaluation |
| Phase 3: Expansion | Months 7-9 | Scale to 100 users, model refinement, user surveys |
| Phase 4: Evaluation | Months 10-11 | Final testing, interviews, statistical validation |
| Phase 5: Writing | Month 12 | Thesis manuscript preparation, defense preparation |

**Total Duration**: 12 months
