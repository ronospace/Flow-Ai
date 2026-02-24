# MSc Data Science Thesis Proposal

**Student:** Geoffrey Rono  
**Matriculation No.:** 74199495  
**Program:** MSc Data Science  
**Supervisor:** Prof. Dr. Iftikhar Ahmed  
**University:** University of Europe for Applied Sciences  
**Date:** October 27, 2025

---

## Title

**Ensemble Machine Learning for Menstrual Cycle Prediction: A Comparative Analysis of Privacy-Preserving On-Device Models for Reproductive Health Monitoring**

---

## Problem Statement

### Healthcare Context
Menstrual cycle tracking affects **1.8 billion women** globally, with 20-30% experiencing irregular cycles requiring medical attention. Critical health conditions like Polycystic Ovary Syndrome (PCOS) affecting 10% of women and Endometriosis affecting another 10% often remain undiagnosed for 7-10 years due to lack of accurate pattern recognition and early detection systems.

### Technical Challenge
Current period tracking applications rely on simple calendar-based predictions with only **60-70% accuracy**, insufficient for reliable health monitoring. These systems face multiple challenges:

1. **Limited Prediction Accuracy:** Simple averaging methods fail to capture complex cycle patterns and individual variability
2. **Privacy Concerns:** Cloud-based ML systems require transmitting sensitive health data to external servers, creating GDPR/HIPAA compliance risks
3. **Lack of Personalization:** Generic models don't adapt to individual user patterns or learn from feedback
4. **Absence of Medical-Grade Features:** No integration of biometric data or early detection of reproductive health conditions
5. **Explainability Gap:** Black-box predictions without confidence scores or contributing factor analysis

### Research Gap
While ensemble learning has proven effective in various healthcare domains, **no comprehensive study exists** comparing ensemble approaches for menstrual cycle prediction that simultaneously addresses:
- Privacy preservation through on-device inference
- Real-time personalization with user feedback loops
- Explainable AI with confidence scoring
- Integration of multi-modal biometric data
- Medical condition pattern recognition (PCOS, Endometriosis)

This thesis aims to fill this gap by developing and evaluating an ensemble ML system that achieves medical-grade accuracy while maintaining complete user privacy through on-device processing.

---

## Research Questions

### Primary Research Questions

**RQ1: Model Effectiveness**  
*How does an ensemble machine learning approach compare to individual algorithms for menstrual cycle prediction accuracy?*
- Hypothesis: Weighted ensemble (SVM + Random Forest + Neural Networks + LSTM + Time Series) achieves ≥15% accuracy improvement over best single model

**RQ2: Privacy-Accuracy Tradeoff**  
*What is the performance impact of privacy-preserving on-device ML inference compared to cloud-based approaches?*
- Hypothesis: On-device TensorFlow Lite inference maintains ≥95% of cloud-equivalent accuracy while ensuring zero data transmission

**RQ3: Real-Time Learning Impact**  
*How does continuous learning from user feedback improve prediction accuracy over time?*
- Hypothesis: User feedback integration improves individual prediction accuracy by ≥10% after 6 cycles compared to static models

**RQ4: Medical Condition Detection**  
*Can ensemble ML models effectively detect patterns indicative of PCOS and Endometriosis from cycle data alone?*
- Hypothesis: Ensemble approach achieves ≥80% sensitivity and ≥75% specificity for PCOS/Endometriosis pattern recognition

### Secondary Research Questions

**RQ5: Feature Importance**  
*Which features (cycle characteristics, temporal, statistical, biometric, symptom) contribute most significantly to prediction accuracy?*

**RQ6: Explainability vs. Accuracy**  
*What is the tradeoff between model complexity and explainability in ensemble healthcare predictions?*

**RQ7: Cross-Platform Performance**  
*How consistent is ML model performance across iOS, Android, and Web platforms?*

---

## Methodology

### Research Design
**Mixed-methods approach** combining quantitative model evaluation with qualitative user study validation.

### Phase 1: Model Development & Implementation (Weeks 1-8)

#### 1.1 Base Model Implementation
Implement and optimize seven individual ML models:

- **Support Vector Machine (SVM)**
  - Kernel: Radial Basis Function (RBF)
  - Hyperparameters: C={0.1, 1.0, 10}, gamma={'scale', 'auto'}
  - Purpose: Cycle irregularity binary classification

- **Random Forest**
  - Estimators: 50-200 trees
  - Max depth: 10-20
  - Purpose: Pattern recognition with feature importance

- **Neural Network (Feedforward)**
  - Architecture: 47→128→64→32→1 (ReLU activation)
  - Dropout: 0.3 for regularization
  - Purpose: Non-linear relationship modeling

- **LSTM (Recurrent Neural Network)**
  - Sequence length: 12 cycles
  - Hidden units: 32-64
  - Purpose: Sequential pattern learning

- **Gaussian Process**
  - Kernel: RBF + White Noise
  - Purpose: Uncertainty quantification, ovulation prediction

- **Bayesian Inference**
  - Prior: Historical population statistics
  - Purpose: Fertility window optimization

- **Time Series Analysis (ARIMA)**
  - Order: (p, d, q) determined via grid search
  - Purpose: Trend and seasonality detection

#### 1.2 Feature Engineering Pipeline
Extract **47-dimensional feature vector** from raw cycle data:

| Feature Category | Count | Examples |
|------------------|-------|----------|
| Cycle Characteristics | 12 | Length, variability, regularity score, phase durations |
| Temporal Features | 8 | Day of cycle, week, month, season |
| Statistical Features | 10 | Mean, std, trends, moving averages, z-scores |
| Biometric Features | 12 | Heart rate, temperature, sleep quality, activity level |
| Symptom Features | 5 | Pain severity, mood, energy, symptom count |

#### 1.3 Ensemble Strategy
Develop weighted ensemble aggregation:

```
Final Prediction = 0.50 × ML_Models + 0.30 × Enhanced_AI + 0.20 × Legacy_AI

where:
  ML_Models = 0.30×SVM + 0.25×RF + 0.30×NN + 0.15×TimeSeries
  Enhanced_AI = 0.40×LSTM + 0.35×GaussianProcess + 0.25×Bayesian
  Legacy_AI = 0.60×HistoricalAvg + 0.40×StatisticalMethods
```

Optimize weights using:
- Grid search with cross-validation
- Individual user performance tuning
- A/B testing framework

### Phase 2: Evaluation & Validation (Weeks 9-14)

#### 2.1 Quantitative Evaluation
**Metrics:**
- Accuracy (% correct predictions ±1 day)
- Precision, Recall, F1-Score
- Mean Absolute Error (MAE) in days
- Confidence interval coverage (95%)
- Inference time (milliseconds)
- Medical condition detection: Sensitivity, Specificity, AUC-ROC

**Validation Strategy:**
- K-fold cross-validation (k=5)
- Temporal validation (train on months 1-6, test on 7-12)
- User-level validation (leave-one-user-out)

#### 2.2 User Study (n ≥ 100 participants)
**Inclusion Criteria:**
- Age 18-45
- Regular app usage (≥3 months)
- Consent for anonymized data research use

**Study Protocol:**
1. Baseline data collection (cycles 1-3)
2. Model prediction deployment (cycles 4-9)
3. User feedback collection after each prediction
4. Medical professional validation (subset n=20 with clinical diagnoses)

**Qualitative Measures:**
- User satisfaction survey (Likert scale 1-5)
- Trust in AI predictions (validated questionnaire)
- Perceived usefulness
- Privacy perception

#### 2.3 Comparative Analysis
Compare against:
- **Baseline:** Simple calendar average
- **Traditional Apps:** Published accuracy rates (60-70%)
- **Individual Models:** Each algorithm standalone
- **Ablation Study:** Remove feature categories to assess importance

### Phase 3: Analysis & Documentation (Weeks 15-20)

#### 3.1 Statistical Analysis
- ANOVA for model comparison significance
- Paired t-tests for ensemble vs individual models
- Regression analysis for feature importance
- Survival analysis for condition detection

#### 3.2 Thesis Writing
Follow proposed 7-chapter structure with emphasis on methodology reproducibility and results transparency.

---

## Dataset

### Primary Dataset: Flow Ai User Data (Proprietary)

#### 3.1 Data Collection
**Source:** Flow Ai mobile application (iOS, Android)  
**Collection Period:** October 2025 - March 2026 (6 months)  
**Target Sample Size:** 500+ users with ≥3 months of tracking data

#### 3.2 Data Structure

**Table 1: Cycles Table**
| Field | Type | Description |
|-------|------|-------------|
| user_id | UUID | Anonymous user identifier (hashed) |
| cycle_id | UUID | Unique cycle identifier |
| start_date | Date | Period start date |
| end_date | Date | Period end date |
| cycle_length | Integer | Days in cycle |
| flow_duration | Integer | Days of bleeding |
| flow_heaviness | Integer | Scale 1-5 |

**Table 2: Symptoms Table**
| Field | Type | Description |
|-------|------|-------------|
| user_id | UUID | Anonymous user identifier |
| date | Date | Symptom date |
| pain_level | Integer | 0-10 scale |
| mood_score | Integer | 1-5 scale |
| energy_level | Integer | 1-5 scale |
| symptom_tags | JSON | Array of symptom categories |

**Table 3: Biometric Data Table**
| Field | Type | Description |
|-------|------|-------------|
| user_id | UUID | Anonymous user identifier |
| date | Date | Measurement date |
| heart_rate | Integer | Resting HR (bpm) |
| temperature | Float | Basal body temp (°C) |
| sleep_hours | Float | Sleep duration |
| activity_steps | Integer | Daily step count |

**Table 4: Predictions Table**
| Field | Type | Description |
|-------|------|-------------|
| prediction_id | UUID | Unique prediction ID |
| user_id | UUID | Anonymous user identifier |
| model_type | String | Algorithm used |
| predicted_date | Date | Predicted period start |
| confidence | Float | 0-1 confidence score |
| actual_date | Date | Actual period start (ground truth) |

**Table 5: Feedback Table**
| Field | Type | Description |
|-------|------|-------------|
| feedback_id | UUID | Unique feedback ID |
| prediction_id | UUID | Related prediction |
| accuracy_rating | Integer | 1-5 user rating |
| actual_vs_predicted | Integer | Days difference |
| timestamp | Timestamp | Feedback submission time |

#### 3.3 Dataset Characteristics

**Estimated Size:**
- Users: 500-1,000
- Total cycles: 3,000-6,000 (avg 6 cycles per user)
- Daily symptom entries: 50,000-100,000
- Biometric data points: 100,000-200,000
- Predictions generated: 10,000-20,000

**Data Quality Measures:**
- Completeness: Track % missing values per field
- Consistency: Validate date ranges, value bounds
- Accuracy: Cross-reference with medical literature (normal ranges)
- Timeliness: Real-time data validation on entry

#### 3.4 Privacy & Ethics

**Anonymization:**
- All PII removed (names, emails, device IDs)
- User IDs cryptographically hashed (SHA-256)
- Location data aggregated to country-level only
- Age bands (18-25, 26-35, 36-45) instead of exact age

**Consent:**
- Explicit opt-in for research participation
- Informed consent form with study details
- Right to withdraw at any time
- Data deletion upon request

**Compliance:**
- GDPR (EU General Data Protection Regulation)
- CCPA (California Consumer Privacy Act)
- HIPAA-compliant architecture (even though not legally required)
- IRB/Ethics committee approval (pending)

**Storage:**
- AES-256 encryption at rest
- Encrypted backups in secure university storage
- Access control (researcher only)
- Retention: 2 years post-study completion, then deletion

### Secondary Dataset: Public Menstrual Cycle Data (Validation)

**Source:** Existing anonymized datasets for validation:
1. **Natural Cycles Dataset** (if accessible through research agreement)
   - 600,000+ users, millions of cycles
   - Published in scientific literature
   
2. **Apple Women's Health Study** (published aggregate data)
   - 10,000+ participants
   - Used for trend validation

**Purpose:** Validate findings generalize beyond Flow Ai user population

### Data Preprocessing Pipeline

```
Raw Data → Validation → Cleaning → Feature Extraction → Normalization → Model Training
```

**Steps:**
1. Remove incomplete cycles (<50% data)
2. Outlier detection (cycle length >45 days or <20 days flagged)
3. Missing value imputation (KNN or mean/median)
4. Feature scaling (z-score normalization)
5. Train/validation/test split (70/15/15)

---

## Expected Outcomes

1. **Ensemble model achieving 85-92% accuracy** for cycle prediction (≥15% improvement over traditional apps)
2. **Privacy-preserving ML framework** demonstrating <5% performance loss vs cloud-based alternatives
3. **Medical condition detection** with 80%+ sensitivity for PCOS/Endometriosis patterns
4. **Open-source research dataset** for future menstrual health ML research
5. **Production-ready application** deployed to iOS/Android app stores

---

## Timeline Summary

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Proposal & Ethics | Weeks 1-2 | Approved proposal, IRB clearance |
| Data Collection | Weeks 3-8 | Dataset with 500+ users |
| Model Development | Weeks 5-10 | Trained ensemble system |
| Evaluation | Weeks 11-14 | Performance benchmarks |
| Writing | Weeks 15-18 | Draft thesis |
| Defense | Weeks 19-20 | Final submission |

**Total Duration:** 20 weeks (5 months)

---

**Signature:**  
Geoffrey Rono  
Email: geoffrey.rono@ue-germany.de  
Date: October 27, 2025
