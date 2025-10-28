# AI-Powered Menstrual Health Prediction System
## Research Proposal Summary for Master of Data Science

**Student**: Geoffrey Rono  
**Program**: Master of Data Science (MSc Data Science)  
**Matriculation No.**: 74199495  
**Email**: geoffrey.rono@ue-germany.de  
**Institution**: University of Europe for Applied Sciences  
**Supervisor**: Prof. Dr. Iftikhar Ahmed, Program Director, Master of Data Science  
**Date**: December 28, 2024

---

## TITLE

**"Development and Validation of an Ensemble Machine Learning System for Personalized Menstrual Cycle Prediction and Health Risk Assessment"**

---

## PROBLEM STATEMENT

Menstrual health affects 1.8 billion women globally, yet current period tracking applications suffer from critical limitations that impact women's health outcomes and quality of life.

**Key Problems**:
1. **Low Accuracy**: Existing apps achieve only 60-75% prediction accuracy, leading to 70%+ abandonment rates
2. **Single-Algorithm Limitations**: Most apps use simple statistical methods rather than advanced ML, failing to capture complex cycle patterns
3. **Privacy Concerns**: Commercial apps often share sensitive health data with third parties without adequate protection
4. **Limited Health Insights**: Current solutions don't detect health anomalies (PCOS, endometriosis) or provide medical-grade insights
5. **Lack of Clinical Validation**: Most apps lack peer-reviewed research or healthcare provider integration

**Impact**: Missed predictions lead to unexpected pregnancies, delayed detection of serious health conditions (PCOS affects 10% of women), and increased healthcare costs. The $15B menstrual health app market needs scientifically validated, privacy-first solutions.

**Research Gap**: There is insufficient research on ensemble ML approaches for menstrual prediction, privacy-preserving health AI, and clinical validation of period tracking technologies.

---

## RESEARCH QUESTIONS

### Primary Question
**RQ1**: Can an ensemble machine learning approach combining SVM, Random Forest, Neural Networks, and LSTM models achieve >90% accuracy in menstrual cycle predictions compared to traditional statistical methods (currently 60-75%)?

### Secondary Questions
**RQ2**: How do different data types (cycle history, symptoms, biometrics, lifestyle) contribute to prediction accuracy?

**RQ3**: Can ML models detect health anomalies (PCOS, endometriosis) with clinically acceptable sensitivity (>85%) and specificity (>90%)?

**RQ4**: Does continuous user feedback improve model accuracy over time, and what is the optimal retraining frequency?

**RQ5**: Can on-device ML with encrypted storage provide comparable accuracy to cloud solutions while maintaining privacy?

**RQ6**: How does model explainability (SHAP/LIME) affect user trust and adoption?

---

## METHODOLOGY

### Research Design
**Mixed-methods approach** combining quantitative ML evaluation, qualitative user studies, A/B testing, and clinical validation over 12 months (January-December 2025).

### System Architecture

**Technology Stack**:
- **Frontend**: Flutter 3.8+ (cross-platform iOS/Android)
- **Backend**: Python FastAPI, Node.js (RESTful/GraphQL)
- **ML Framework**: TensorFlow 2.12, PyTorch 2.0, Scikit-learn 1.3
- **Deployment**: TensorFlow Lite (on-device), ONNX
- **Security**: AES-256 encryption, TLS 1.3, GDPR/HIPAA-compliant

### Machine Learning Approach

**Ensemble Architecture** - Weighted combination of four complementary models:

1. **Support Vector Machine (30%)**: Cycle length classification using RBF kernel
2. **Random Forest (25%)**: Symptom pattern recognition with 100 trees
3. **Neural Network (30%)**: Deep learning (3 layers: 128-64-32 neurons) for complex patterns
4. **LSTM (15%)**: Sequential learning with 12-cycle memory for temporal dependencies

**Feature Engineering**:
- 120+ features including temporal patterns, symptoms (70+), biometrics (heart rate, sleep, temperature), lifestyle factors
- Transformations: StandardScaler normalization, one-hot encoding, rolling averages, derived metrics

**Training Process**:
- 80% training, 10% validation, 10% test (temporal split)
- Grid Search hyperparameter tuning with 5-fold cross-validation
- Ensemble weight optimization based on validation performance
- Weekly retraining with new user data

---

### Datasets

**Primary Dataset: Flow Ai Real Tester Data**
- **Source**: Real tester data from Flow Ai app, EU-hosted Firebase Firestore (eur3 region)
- **Pilot Users**: ~10-30 real testers (target: scale to ~100)
- **Tracking Duration**: 1-3 complete cycles per tester
- **Data Volume**: ~200-600 daily tracking logs (realistic current state)
- **Features**: Cycle dates, flow intensity, symptoms, mood/energy, biometrics
- **Collection Period**: Ongoing pilot testing
- **Ethics**: Anonymized consent obtained, GDPR-compliant EU storage

**Supplementary Dataset: Small Synthetic Augmentation** (Only if Needed)
- **Purpose**: Improve model robustness only if necessary
- **Approach**: Clearly documented as synthetic in thesis
- **Volume**: Minimal - primary results always based on real tester data

**Data Preprocessing**:
- Anonymization of real tester data from Firebase Firestore
- Missing data handling and outlier detection
- Per-user normalization for personalization
- Standard ML preprocessing pipeline

---

### Evaluation Metrics

**Prediction Accuracy** (sufficient for pilot dataset ~200-600 records):
- Classification: Precision, Recall, F1-Score
- Time-series: MAE, RMSE for cycle prediction
- Pattern Detection: Clustering analysis for symptom patterns

**User Experience** (Mixed-Methods):
- Quantitative: ML prediction performance metrics
- Qualitative: User surveys/interviews on trust, usefulness, privacy perception

---

### Experimental Procedure (12 Months)

**Phase 1 (Months 1-3)**: Complete real tester data collection (~10-30 users, 1-3 cycles), anonymization, preprocessing

**Phase 2 (Months 4-6)**: Train ML models on real tester data, ensemble development, hyperparameter tuning

**Phase 3 (Months 7-9)**: Validation testing, user surveys/interviews, mixed-methods analysis

**Phase 4 (Months 10-11)**: Model refinement, explainability features, user feedback integration

**Phase 5 (Month 12)**: Final evaluation, thesis writing, submission preparation

---

### Comparison with Existing Solutions

| Metric | Simple Avg | Flo App | Clue App | **Flow Ai (Target)** |
|--------|-----------|---------|----------|---------------------|
| Accuracy (±1d) | 65% | 72% | 75% | **>90%** ✓ |
| PCOS Detection | N/A | N/A | N/A | **>85%** ✓ |
| Privacy | Low | Medium | High | **Very High** ✓ |
| Explainability | None | None | None | **SHAP/LIME** ✓ |

---

## EXPECTED OUTCOMES

### Deliverables
1. Cross-platform mobile app (iOS/Android) with >90% accuracy
2. Trained ensemble ML models (open-sourced for research)
3. Master's thesis with comprehensive methodology and results
4. Peer-reviewed journal publication submission
5. Anonymized dataset for research community

### Success Criteria
- **Primary**: Achieve >90% cycle prediction accuracy (±1 day)
- **Secondary**: PCOS/Endometriosis detection >85% sensitivity
- **Tertiary**: Deploy to 10,000+ users with >80% retention

### Impact
- **Technical**: Novel ensemble architecture for healthcare AI
- **Scientific**: Largest validated menstrual health ML dataset, peer-reviewed publications
- **Practical**: Improved women's health outcomes, early condition detection, privacy-first architecture

---

## TIMELINE & BUDGET

**Timeline**: January - December 2025 (12 months)

**Budget**: $14,724
- Cloud GPU training: $6,000
- AWS infrastructure: $3,600
- User incentives: $5,000
- Licenses: $124

---

## CONTACT

**Student**: Geoffrey Rono  
**Matriculation No.**: 74199495  
**Email**: geoffrey.rono@ue-germany.de  
**GitHub**: github.com/ronospace/ZyraFlow  

**Supervisor**: Prof. Dr. Iftikhar Ahmed  
**Position**: Program Director, Master of Data Science

**Submitted**: December 28, 2024  
**Institution**: University of Europe for Applied Sciences

---

*This research addresses a critical gap in women's health technology through rigorous ML methodology, clinical validation, and privacy-first design, with potential to impact 1.8 billion women globally.*
