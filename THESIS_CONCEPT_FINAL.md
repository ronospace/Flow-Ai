# 📄 Flow-AI: Machine Learning for Menstrual Health Prediction
## Thesis Concept Document

**Student**: Geoffrey Kipngetich Rono  
**Matriculation No.**: 74199495  
**Program**: MSc Data Science (90 ECTS)  
**University**: University of Europe for Applied Sciences  
**Supervisor**: Prof. Dr. Iftikhar Ahmed  
**Date**: October 28, 2025

---

## 1. Title

**Flow-AI: Machine Learning for Cycle Prediction and Symptom Intelligence in Menstrual Health Tracking**

---

## 2. Problem Statement

Menstrual health tracking applications serve over **200 million users globally**, yet most rely on simple rule-based algorithms that assume regular 28-day cycles. Research shows these methods achieve only **60-75% prediction accuracy**, leading to high abandonment rates (over 70% within 3 months).

### Key Challenges:
- **Individual Variability**: Cycles vary significantly due to stress, hormonal changes, lifestyle factors, and health conditions
- **Limited Personalization**: Current apps fail to adapt to users' unique cycle patterns
- **Trust Deficit**: Poor predictions erode user confidence in digital health tools
- **Research Gap**: Limited peer-reviewed studies evaluating ML effectiveness in real-world menstrual health contexts

### Research Gap:
While commercial apps exist, there is **insufficient academic research** on:
1. Comparative effectiveness of ML vs. rule-based menstrual predictions
2. Symptom-cycle phase correlations using real-world user data
3. User trust and acceptance of AI-driven health predictions
4. Privacy-preserving ML methodologies in sensitive health tracking

**Flow-AI** addresses this gap by providing a scientifically rigorous evaluation platform combining technical ML performance with real-world user perception analysis.

---

## 3. Research Questions

### Primary Research Question
**RQ1**: How accurately can ensemble machine learning models (Random Forest, LSTM, clustering) predict menstrual cycle phases compared to traditional rule-based methods?

### Secondary Research Questions
**RQ2**: Which symptoms demonstrate statistically significant correlation with menstrual cycle phases based on longitudinal user tracking data?

**RQ3**: How do users perceive the usefulness, accuracy, trustworthiness, and privacy implications of AI-driven menstrual health predictions?

**RQ4**: What factors (data quantity, cycle regularity, symptom logging consistency) most influence prediction accuracy?

---

## 4. Methodology

### 4.1 Research Design
**Mixed-Methods Approach** combining quantitative ML evaluation with qualitative user experience research.

### 4.2 Quantitative Component

#### Data Source
- **Platform**: Flow-AI mobile application (Flutter, deployed on iOS/Android/Web)
- **Collection Period**: 12 months (phased approach)
- **Storage**: Firebase Firestore (EU region: eur3) - GDPR compliant

#### Dataset Scale (Phased Approach)

**Phase 1: Pilot Study (Months 1-3)**
- Target: 30-50 beta testers
- Expected: 500-1,000 daily tracking entries
- Purpose: Model development, initial validation

**Phase 2: Expansion (Months 4-8)**
- Target: 500-800 active users
- Expected: 10,000-15,000 daily entries
- Purpose: Model refinement, robustness testing

**Phase 3: Full Deployment (Months 9-12)**
- Target: 1,000+ active users
- Expected: 20,000-30,000 daily entries
- Purpose: Final evaluation, comparative analysis

#### Features Collected
- **Cycle Data**: Start/end dates, flow intensity (5 levels), cycle length
- **Symptoms**: 70+ tracked symptoms with severity ratings (1-10 scale)
- **Mood & Energy**: Daily mood states, energy levels
- **Lifestyle**: Sleep quality, stress levels, exercise
- **Biometrics** (optional): Temperature, heart rate (via wearable integration)

#### Machine Learning Pipeline

**1. Data Preprocessing**
- Anonymization (remove all PII before analysis)
- Missing data imputation (KNN, forward-fill for time series)
- Outlier detection (IQR method, physiologically plausible ranges)
- Feature engineering (rolling averages, lagged features, cycle phase encoding)

**2. Model Development**
- **Baseline**: Simple averaging, calendar-based prediction
- **Random Forest**: Cycle length classification, symptom pattern recognition
- **LSTM Networks**: Sequential cycle pattern learning (12-cycle memory)
- **Clustering**: K-means for symptom grouping and cycle pattern identification
- **Ensemble Approach**: Weighted combination of models

**3. Training Strategy**
- Temporal split: 80% training, 10% validation, 10% test
- Cross-validation: 5-fold time-series cross-validation
- Hyperparameter tuning: Grid search with validation set

#### Evaluation Metrics
- **Cycle Prediction**: MAE (days), RMSE, accuracy within ±1 day, ±2 days
- **Classification**: Precision, Recall, F1-score (for phase prediction)
- **Symptom Correlation**: Pearson/Spearman correlation coefficients, p-values
- **Model Comparison**: Friedman test, Wilcoxon signed-rank test

### 4.3 Qualitative Component

#### Participants
- Subset of 50-100 active Flow-AI users
- Stratified sampling: regular vs. irregular cycles, high vs. low app engagement

#### Data Collection Methods
1. **In-App Surveys** (n=100+)
   - Prediction accuracy perception (5-point Likert scale)
   - Trust in AI recommendations
   - Feature usefulness ratings
   - Privacy concern assessment

2. **Semi-Structured Interviews** (n=15-20)
   - Deep dive into user mental models of AI predictions
   - Understanding of confidence scores and explanations
   - Impact on health decision-making
   - Privacy and data control preferences

#### Analysis Approach
- **Thematic Analysis**: NVivo or MAXQDA for coding and theme identification
- **Sentiment Analysis**: Automated analysis of free-text feedback
- **Triangulation**: Cross-validate quantitative metrics with qualitative insights

### 4.4 Comparative Benchmarking
- **Baseline 1**: Simple averaging (last 3 cycles)
- **Baseline 2**: Calendar method (28-day assumption)
- **Comparison**: Published accuracy of commercial apps (Flo: ~72%, Clue: ~75%)
- **Target**: >80% accuracy (±1 day), demonstrating ML improvement

---

## 5. Dataset Identification & Ethics

### 5.1 Primary Dataset
- **Source**: Real user data from Flow-AI testers
- **Storage**: Google Firebase Firestore, EU region (eur3)
- **Compliance**: GDPR, informed consent, data minimization
- **Expected Scale**: 
  - Pilot: 500-1,000 entries (30-50 users)
  - Full: 20,000-30,000 entries (1,000+ users)

### 5.2 Data Privacy & Security
✅ **Anonymization**: All PII removed before export for analysis  
✅ **Consent**: Explicit informed consent from all participants  
✅ **Encryption**: AES-256 at rest, TLS 1.3 in transit  
✅ **Access Control**: Role-based access, audit logs  
✅ **User Rights**: Data deletion, opt-out, data portability  
✅ **Purpose Limitation**: Data used solely for academic research  

### 5.3 Ethical Considerations
- **No Medical Claims**: Predictions are informational, not diagnostic
- **Transparency**: Users informed about AI limitations and confidence levels
- **Bias Mitigation**: Diverse user representation, fairness evaluation
- **Ethics Approval**: University IRB/ethics committee approval before data collection
- **Synthetic Data**: Minimal use, clearly documented if needed for edge cases

---

## 6. Expected Contributions

### 6.1 Technical Contributions
- **Validated ML Architecture**: Ensemble models (Random Forest + LSTM) for menstrual cycle prediction
- **Feature Importance Analysis**: Identification of most predictive features for cycle accuracy
- **Symptom-Cycle Correlations**: Statistical evidence of symptom timing relative to cycle phases
- **Privacy-Preserving Pipeline**: Methodology for ethical health data analysis

### 6.2 Scientific Contributions
- **Empirical Evidence**: Peer-reviewed validation of ML effectiveness with real-world data (1,000+ users)
- **Comparative Analysis**: ML vs. rule-based methods with statistical significance testing
- **Mixed-Methods Framework**: Integration of quantitative performance and qualitative user perception
- **Reproducible Methodology**: Open methodology for FemTech ML research

### 6.3 Practical Contributions
- **User Trust Framework**: Evidence-based guidelines for AI health prediction acceptance
- **Design Recommendations**: UX principles for explainable AI in sensitive health contexts
- **Scalability Insights**: Lessons for deploying ML-powered health apps
- **Industry Benchmarking**: Academic comparison with commercial solutions

---

## 7. Timeline

| Phase | Months | Key Activities | Deliverables |
|-------|---------|----------------|--------------|
| **Phase 1**: Pilot | 1-3 | Recruit beta testers, collect initial data, develop baseline models | Dataset (500-1K entries), baseline models |
| **Phase 2**: Development | 4-6 | ML model training, hyperparameter tuning, initial evaluation | Trained models, preliminary results |
| **Phase 3**: Expansion | 7-9 | Scale to 500-1,000 users, refine models, user surveys | Expanded dataset (10K-20K entries), survey data |
| **Phase 4**: Evaluation | 10-11 | Final testing, comparative analysis, interviews, statistical validation | Complete results, interview transcripts |
| **Phase 5**: Thesis Writing | 11-12 | Manuscript preparation, peer review submission, defense preparation | Master's thesis, journal paper draft |

**Total Duration**: 12 months

---

## 8. Technical Infrastructure

### Application
- **Platform**: Flutter 3.35.2 (cross-platform iOS/Android/Web)
- **Backend**: Firebase Firestore (EU region)
- **Hosting**: https://flow-iq-app.web.app
- **Status**: ✅ Production-ready, actively collecting data

### Code Repositories
- **Main**: https://github.com/ronospace/ZyraFlow.git
- **Backup**: https://github.com/ronospace/Flow-Ai.git
- **Branch**: `source-only-backup`
- **Visibility**: Private (academic research)

### Development Environment
- **ML Stack**: Python 3.10+, scikit-learn, TensorFlow/PyTorch, pandas, NumPy
- **Analysis**: Jupyter Notebooks, R (optional for statistics)
- **Visualization**: Matplotlib, Seaborn, Plotly
- **Qualitative**: NVivo/MAXQDA for thematic analysis

---

## 9. Risk Mitigation

### Technical Risks
- **Low User Recruitment**: Mitigate with marketing, incentives, university partnerships
- **Data Quality Issues**: Implement validation rules, user feedback loops, data cleaning pipelines
- **Model Underperformance**: Use ensemble methods, extensive hyperparameter tuning, baseline comparisons

### Ethical Risks
- **Privacy Breach**: Strong encryption, anonymization, regular security audits
- **User Harm**: Clear disclaimers, no medical advice, informational predictions only
- **Bias**: Diverse recruitment, fairness metrics, bias detection algorithms

---

## 10. Success Criteria

### Minimum Viable Success
- ✅ Collect data from 500+ users (10,000+ entries)
- ✅ Achieve >75% prediction accuracy (±1 day) - matching/exceeding commercial apps
- ✅ Complete 50+ user surveys
- ✅ Statistical significance in ML vs. baseline comparison (p < 0.05)

### Target Success
- 🎯 Collect data from 1,000+ users (20,000+ entries)
- 🎯 Achieve >80% prediction accuracy (±1 day)
- 🎯 Complete 100+ surveys + 15-20 interviews
- 🎯 Identify 5+ statistically significant symptom-cycle correlations
- 🎯 Publish in peer-reviewed journal (JMIR mHealth, npj Digital Medicine)

---

## 11. Limitations & Future Work

### Acknowledged Limitations
- **Sample Size**: While larger than typical academic studies, still smaller than commercial datasets
- **Self-Reported Data**: Reliance on user accuracy in symptom tracking
- **Demographic Scope**: Primarily European users (generalizability considerations)
- **Short Duration**: 12-month study may not capture long-term cycle changes

### Future Research Directions
- Longitudinal study over multiple years
- Integration with wearable biometric data
- Expansion to underrepresented populations
- Clinical validation with medical professionals

---

## 12. References (Preliminary)

1. Li, K., et al. (2020). "Accuracy of menstrual cycle prediction apps." *Obstetrics & Gynecology*, 135(3), 656-663.
2. Moglia, M. L., et al. (2016). "Evaluation of smartphone menstrual cycle tracking applications." *Obstetrics & Gynecology*, 127(6), 1153-1160.
3. Bull, J. R., et al. (2019). "Real-world menstrual cycle characteristics." *NPJ Digital Medicine*, 2(1), 1-8.
4. Hochreiter, S., & Schmidhuber, J. (1997). "Long short-term memory." *Neural Computation*, 9(8), 1735-1780.

*(Full reference list will be completed during thesis development)*

---

## 📋 Document Status

✅ **Ready for Supervisor Review**

**Next Steps**:
1. Submit to Prof. Dr. Iftikhar Ahmed for feedback
2. Schedule meeting to discuss scope, timeline, ethics
3. Address any supervisor concerns or modifications
4. Submit to university ethics committee for approval
5. Begin formal data collection upon approval

---

**Student Contact**:  
Geoffrey Kipngetich Rono  
Email: geoffrey.rono@ue-germany.de  
Matriculation No.: 74199495

**Supervisor Contact**:  
Prof. Dr. Iftikhar Ahmed  
Program Director, Master of Data Science  
University of Europe for Applied Sciences  
Email: iftikhar.ahmed@ue-germany.de

---

*This document represents the finalized thesis concept as of October 28, 2025, and supersedes all previous versions.*
