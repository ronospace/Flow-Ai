# 📄 Flow-AI Thesis Concept Document

**Submitted to**: Prof. Dr. Iftikhar Ahmed  
**Student**: Geoffrey Kipngetich Rono  
**Matriculation No.**: 74199495  
**Program**: MSc Data Science (90 ECTS)  
**University**: University of Europe for Applied Sciences  
**Date**: October 28, 2025

---

## ✅ Title

**Flow-AI: Machine Learning for Cycle Prediction and Symptom Intelligence in Menstrual Health Tracking**

---

## ✅ Problem Statement

Menstrual cycle prediction apps are widely used, yet many still rely on simple rule-based methods that assume regular cycles and ignore individual variability. This often leads to inaccurate predictions, causing reduced trust and limited usefulness for users with irregular or changing cycle patterns.

There is a growing need for a personalized, data-driven approach in FemTech—one that adapts to a user's unique cycle history, identifies symptom correlations, and provides more reliable predictions. However, there is limited academic research evaluating the effectiveness of machine learning models in real-world menstrual health tracking, particularly in terms of user trust and perceived value.

**Flow-AI** introduces a modern prediction system that integrates user-reported data and machine learning while evaluating both technical performance and user experience.

---

## ✅ Research Questions

**RQ1**: How accurately can machine learning models predict menstrual cycle phases compared to traditional rule-based methods?

**RQ2**: Which symptoms show significant correlation with menstrual cycle phases based on real user logs?

**RQ3**: How do users perceive the usefulness, accuracy, and trustworthiness of AI-driven menstrual predictions?

---

## ✅ Methodology

This research adopts a **mixed-methods approach**:

### Quantitative Analysis

- **Data Source**: Cycle logs collected via Flow-AI app
- **ML Techniques**: Time-series analysis, Random Forest, LSTM, clustering for symptom patterns
- **Metrics**: MAE (Mean Absolute Error), RMSE (Root Mean Square Error), Precision, Recall, F1-score
- **Outcome**: Evaluate prediction accuracy and identify symptom relationships

### Qualitative Analysis

- **Participants**: Current real testers using Flow-AI
- **Method**: Short user surveys and optional interviews
- **Analysis**: Thematic coding to assess user trust, usability, perceived accuracy, and privacy concerns
- **Outcome**: Validate real-world acceptability and app impact

This combination enables a **holistic evaluation** of AI-driven menstrual health insights.

---

## ✅ Dataset Identification

### Primary Dataset
- **Source**: Anonymized menstrual cycle and symptom logs from real Flow-AI testers
- **Storage**: Google Firebase Firestore — EU data region (eur3) — GDPR-compliant
- **Expected Sample Size**: ~10–30 active testers, contributing 200–600 daily tracking entries
- **Features**: Cycle dates, flow intensity, 70+ symptoms with severity, mood/energy levels, pain mapping

### Supplemental Data
- **Purpose**: Small synthetic augmentation if needed for improved model robustness
- **Documentation**: Clearly labeled as synthetic in all analyses

### Privacy & Compliance
- ✅ No personally identifiable data exported
- ✅ Informed consent collected from all testers
- ✅ GDPR-compliant EU data storage

---

## ✅ Ethical Considerations

All health-related data will be **anonymized** before analysis, and **informed consent** will be obtained from all testers. The research will strictly follow **GDPR guidelines** for sensitive data handling. 

Key ethical commitments:
- Users can opt out of data collection at any time
- Data used solely for academic research purposes
- No commercial exploitation of personal health data
- Predictions are informational, not diagnostic

---

## ✅ Expected Contributions

### Technical Contributions
- Validated ML models for menstrual cycle prediction using real-world pilot data
- Symptom correlation analysis with cycle phases
- Comparison of ML approaches (Random Forest, LSTM) vs. traditional methods

### Scientific Contributions
- Empirical evidence of ML effectiveness in menstrual health tracking
- Mixed-methods evaluation combining quantitative metrics and qualitative user feedback
- Privacy-preserving methodology for FemTech research

### Practical Contributions
- Improved user trust and acceptance framework for AI health predictions
- Real-world deployment insights for menstrual health applications
- Guidelines for ethical AI in sensitive health tracking

---

## ✅ Timeline (Proposed)

| Phase | Duration | Key Activities |
|-------|----------|----------------|
| Phase 1 | 3 months | Data collection, anonymization, preprocessing |
| Phase 2 | 3 months | ML model training, evaluation |
| Phase 3 | 3 months | User surveys, qualitative analysis |
| Phase 4 | 2 months | Results analysis, optimization |
| Phase 5 | 1 month | Thesis writing, submission |

**Total**: 12 months

---

## ✅ Technical Infrastructure

### Application
- **Platform**: Flutter (cross-platform iOS/Android/Web)
- **Backend**: Firebase Firestore (EU region)
- **Hosting**: https://flow-iq-app.web.app

### Code Repository
- **Main**: https://github.com/ronospace/ZyraFlow.git
- **Backup**: https://github.com/ronospace/Flow-Ai.git
- **Branch**: `source-only-backup`

### Development Status
- ✅ Production app deployed and active
- ✅ Real tester data collection infrastructure ready
- ✅ Privacy-compliant architecture implemented
- ✅ ML prediction framework operational

---

## 📋 Document Status

✅ **Document complete and ready for supervisor evaluation**

**Next Steps**:
1. Submit to Prof. Dr. Iftikhar Ahmed for review
2. Schedule follow-up meeting to discuss
3. Await approval for thesis registration
4. Begin formal data collection upon approval

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

*This document supersedes all previous research proposal versions and represents the finalized thesis concept as of October 28, 2025.*
