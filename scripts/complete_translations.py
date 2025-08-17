#!/usr/bin/env python3
"""
Translation completion script for FlowSense ARB files.
Completes missing translations for all supported languages.
"""
import json
import os
import sys
import re
from pathlib import Path

# Translation mappings for key languages
TRANSLATIONS = {
    'de': {
        'appName': 'FlowSense',
        'appTagline': 'KI-gestützte Perioden- & Zyklus-Verfolgung',
        'appDescription': 'Verfolgen Sie Ihren Menstruationszyklus mit KI-gestützten Einblicken und personalisierten Empfehlungen für eine bessere reproduktive Gesundheit.',
        'home': 'Startseite',
        'calendar': 'Kalender',
        'tracking': 'Verfolgung',
        'insights': 'Einblicke',
        'settings': 'Einstellungen',
        'menstrualPhase': 'Menstrual',
        'follicularPhase': 'Follikulär',
        'ovulatoryPhase': 'Ovulation',
        'lutealPhase': 'Luteal',
        'fertileWindow': 'Fruchtbares Fenster',
        'ovulationDay': 'Eisprung-Tag',
        'periodStarted': 'Periode begonnen',
        'periodEnded': 'Periode beendet',
        'flowIntensity': 'Blutungsstärke',
        'flowNone': 'Keine',
        'flowSpotting': 'Schmierblutung',
        'flowLight': 'Leicht',
        'flowMedium': 'Mittel',
        'flowHeavy': 'Stark',
        'flowVeryHeavy': 'Sehr stark',
        'symptoms': 'Symptome',
        'noSymptoms': 'Keine Symptome',
        'cramps': 'Krämpfe',
        'bloating': 'Blähungen',
        'headache': 'Kopfschmerzen',
        'backPain': 'Rückenschmerzen',
        'breastTenderness': 'Brustspannen',
        'fatigue': 'Müdigkeit',
        'moodSwings': 'Stimmungsschwankungen',
        'acne': 'Akne',
        'nausea': 'Übelkeit',
        'cravings': 'Heißhunger',
        'insomnia': 'Schlaflosigkeit',
        'hotFlashes': 'Hitzewallungen',
        'coldFlashes': 'Kälteschauer',
        'diarrhea': 'Durchfall',
        'constipation': 'Verstopfung',
        'mood': 'Stimmung',
        'energy': 'Energie',
        'pain': 'Schmerz',
        'moodHappy': 'Glücklich',
        'moodNeutral': 'Neutral',
        'moodSad': 'Traurig',
        'moodAnxious': 'Ängstlich',
        'moodIrritated': 'Gereizt',
        'energyHigh': 'Hohe Energie',
        'energyMedium': 'Mittlere Energie',
        'energyLow': 'Niedrige Energie',
        'painNone': 'Keine Schmerzen',
        'painMild': 'Leichte Schmerzen',
        'painModerate': 'Mäßige Schmerzen',
        'painSevere': 'Starke Schmerzen',
        'predictions': 'Vorhersagen',
        'nextPeriod': 'Nächste Periode',
        'nextOvulation': 'Nächster Eisprung',
        'save': 'Speichern',
        'cancel': 'Abbrechen',
        'delete': 'Löschen',
        'edit': 'Bearbeiten',
        'update': 'Aktualisieren',
        'yes': 'Ja',
        'no': 'Nein',
        'ok': 'OK',
        'close': 'Schließen'
    },
    'es': {
        'appName': 'FlowSense',
        'appTagline': 'Seguimiento de Períodos y Ciclos con IA',
        'appDescription': 'Rastrea tu ciclo menstrual con información impulsada por IA y recomendaciones personalizadas para una mejor salud reproductiva.',
        'home': 'Inicio',
        'calendar': 'Calendario',
        'tracking': 'Seguimiento',
        'insights': 'Perspectivas',
        'settings': 'Configuración',
        'menstrualPhase': 'Menstrual',
        'follicularPhase': 'Folicular',
        'ovulatoryPhase': 'Ovulatorio',
        'lutealPhase': 'Lútea',
        'fertileWindow': 'Ventana Fértil',
        'ovulationDay': 'Día de Ovulación',
        'periodStarted': 'Período Iniciado',
        'periodEnded': 'Período Terminado',
        'flowIntensity': 'Intensidad del Flujo',
        'flowNone': 'Ninguno',
        'flowSpotting': 'Manchado',
        'flowLight': 'Ligero',
        'flowMedium': 'Medio',
        'flowHeavy': 'Abundante',
        'flowVeryHeavy': 'Muy Abundante',
        'symptoms': 'Síntomas',
        'noSymptoms': 'Sin síntomas',
        'cramps': 'Cólicos',
        'bloating': 'Hinchazón',
        'headache': 'Dolor de cabeza',
        'backPain': 'Dolor de espalda',
        'breastTenderness': 'Sensibilidad en senos',
        'fatigue': 'Fatiga',
        'moodSwings': 'Cambios de humor',
        'acne': 'Acné',
        'nausea': 'Náuseas',
        'cravings': 'Antojos',
        'insomnia': 'Insomnio',
        'hotFlashes': 'Sofocos',
        'coldFlashes': 'Escalofríos',
        'diarrhea': 'Diarrea',
        'constipation': 'Estreñimiento',
        'mood': 'Estado de ánimo',
        'energy': 'Energía',
        'pain': 'Dolor',
        'moodHappy': 'Feliz',
        'moodNeutral': 'Neutral',
        'moodSad': 'Triste',
        'moodAnxious': 'Ansiosa',
        'moodIrritated': 'Irritada',
        'energyHigh': 'Energía Alta',
        'energyMedium': 'Energía Media',
        'energyLow': 'Energía Baja',
        'painNone': 'Sin Dolor',
        'painMild': 'Dolor Leve',
        'painModerate': 'Dolor Moderado',
        'painSevere': 'Dolor Severo',
        'predictions': 'Predicciones',
        'nextPeriod': 'Próximo Período',
        'nextOvulation': 'Próxima Ovulación',
        'save': 'Guardar',
        'cancel': 'Cancelar',
        'delete': 'Eliminar',
        'edit': 'Editar',
        'update': 'Actualizar',
        'yes': 'Sí',
        'no': 'No',
        'ok': 'OK',
        'close': 'Cerrar'
    },
    'fr': {
        'appName': 'FlowSense',
        'appTagline': 'Suivi des Règles et Cycles avec IA',
        'appDescription': 'Suivez votre cycle menstruel avec des informations alimentées par l\'IA et des recommandations personnalisées pour une meilleure santé reproductive.',
        'home': 'Accueil',
        'calendar': 'Calendrier',
        'tracking': 'Suivi',
        'insights': 'Perspectives',
        'settings': 'Paramètres',
        'menstrualPhase': 'Menstruel',
        'follicularPhase': 'Folliculaire',
        'ovulatoryPhase': 'Ovulatoire',
        'lutealPhase': 'Lutéale',
        'fertileWindow': 'Fenêtre Fertile',
        'ovulationDay': 'Jour d\'Ovulation',
        'periodStarted': 'Règles Commencées',
        'periodEnded': 'Règles Terminées',
        'flowIntensity': 'Intensité du Flux',
        'flowNone': 'Aucun',
        'flowSpotting': 'Spotting',
        'flowLight': 'Léger',
        'flowMedium': 'Moyen',
        'flowHeavy': 'Abondant',
        'flowVeryHeavy': 'Très Abondant',
        'symptoms': 'Symptômes',
        'noSymptoms': 'Aucun symptôme',
        'cramps': 'Crampes',
        'bloating': 'Ballonnements',
        'headache': 'Mal de tête',
        'backPain': 'Mal de dos',
        'breastTenderness': 'Sensibilité des seins',
        'fatigue': 'Fatigue',
        'moodSwings': 'Sautes d\'humeur',
        'acne': 'Acné',
        'nausea': 'Nausées',
        'cravings': 'Envies',
        'insomnia': 'Insomnie',
        'hotFlashes': 'Bouffées de chaleur',
        'coldFlashes': 'Frissons',
        'diarrhea': 'Diarrhée',
        'constipation': 'Constipation',
        'mood': 'Humeur',
        'energy': 'Énergie',
        'pain': 'Douleur',
        'moodHappy': 'Heureuse',
        'moodNeutral': 'Neutre',
        'moodSad': 'Triste',
        'moodAnxious': 'Anxieuse',
        'moodIrritated': 'Irritée',
        'energyHigh': 'Énergie Élevée',
        'energyMedium': 'Énergie Moyenne',
        'energyLow': 'Énergie Faible',
        'painNone': 'Pas de Douleur',
        'painMild': 'Douleur Légère',
        'painModerate': 'Douleur Modérée',
        'painSevere': 'Douleur Sévère',
        'predictions': 'Prédictions',
        'nextPeriod': 'Prochaines Règles',
        'nextOvulation': 'Prochaine Ovulation',
        'save': 'Enregistrer',
        'cancel': 'Annuler',
        'delete': 'Supprimer',
        'edit': 'Éditer',
        'update': 'Mettre à jour',
        'yes': 'Oui',
        'no': 'Non',
        'ok': 'OK',
        'close': 'Fermer'
    },
    'it': {
        'appName': 'FlowSense',
        'appTagline': 'Tracciamento Cicli e Mestruazioni con IA',
        'appDescription': 'Traccia il tuo ciclo mestruale con informazioni basate sull\'IA e raccomandazioni personalizzate per una migliore salute riproduttiva.',
        'home': 'Home',
        'calendar': 'Calendario',
        'tracking': 'Tracciamento',
        'insights': 'Approfondimenti',
        'settings': 'Impostazioni',
        'menstrualPhase': 'Mestruale',
        'follicularPhase': 'Follicolare',
        'ovulatoryPhase': 'Ovulatoria',
        'lutealPhase': 'Luteale',
        'fertileWindow': 'Finestra Fertile',
        'ovulationDay': 'Giorno di Ovulazione',
        'periodStarted': 'Ciclo Iniziato',
        'periodEnded': 'Ciclo Terminato',
        'flowIntensity': 'Intensità del Flusso',
        'flowNone': 'Nessuno',
        'flowSpotting': 'Spotting',
        'flowLight': 'Leggero',
        'flowMedium': 'Medio',
        'flowHeavy': 'Abbondante',
        'flowVeryHeavy': 'Molto Abbondante',
        'symptoms': 'Sintomi',
        'noSymptoms': 'Nessun sintomo',
        'cramps': 'Crampi',
        'bloating': 'Gonfiore',
        'headache': 'Mal di testa',
        'backPain': 'Mal di schiena',
        'breastTenderness': 'Sensibilità del seno',
        'fatigue': 'Affaticamento',
        'moodSwings': 'Sbalzi d\'umore',
        'acne': 'Acne',
        'nausea': 'Nausea',
        'cravings': 'Voglie',
        'insomnia': 'Insonnia',
        'hotFlashes': 'Vampate di calore',
        'coldFlashes': 'Brividi',
        'diarrhea': 'Diarrea',
        'constipation': 'Stitichezza',
        'mood': 'Umore',
        'energy': 'Energia',
        'pain': 'Dolore',
        'moodHappy': 'Felice',
        'moodNeutral': 'Neutro',
        'moodSad': 'Triste',
        'moodAnxious': 'Ansiosa',
        'moodIrritated': 'Irritata',
        'energyHigh': 'Alta Energia',
        'energyMedium': 'Media Energia',
        'energyLow': 'Bassa Energia',
        'painNone': 'Nessun Dolore',
        'painMild': 'Dolore Lieve',
        'painModerate': 'Dolore Moderato',
        'painSevere': 'Dolore Severo',
        'predictions': 'Previsioni',
        'nextPeriod': 'Prossimo Ciclo',
        'nextOvulation': 'Prossima Ovulazione',
        'save': 'Salva',
        'cancel': 'Annulla',
        'delete': 'Elimina',
        'edit': 'Modifica',
        'update': 'Aggiorna',
        'yes': 'Sì',
        'no': 'No',
        'ok': 'OK',
        'close': 'Chiudi'
    },
    'pt': {
        'appName': 'FlowSense',
        'appTagline': 'Rastreamento de Períodos e Ciclos com IA',
        'appDescription': 'Rastreie seu ciclo menstrual com insights alimentados por IA e recomendações personalizadas para melhor saúde reprodutiva.',
        'home': 'Início',
        'calendar': 'Calendário',
        'tracking': 'Rastreamento',
        'insights': 'Insights',
        'settings': 'Configurações',
        'menstrualPhase': 'Menstrual',
        'follicularPhase': 'Folicular',
        'ovulatoryPhase': 'Ovulatória',
        'lutealPhase': 'Lútea',
        'fertileWindow': 'Janela Fértil',
        'ovulationDay': 'Dia da Ovulação',
        'periodStarted': 'Período Iniciado',
        'periodEnded': 'Período Terminado',
        'flowIntensity': 'Intensidade do Fluxo',
        'flowNone': 'Nenhum',
        'flowSpotting': 'Escape',
        'flowLight': 'Leve',
        'flowMedium': 'Médio',
        'flowHeavy': 'Intenso',
        'flowVeryHeavy': 'Muito Intenso',
        'symptoms': 'Sintomas',
        'noSymptoms': 'Sem sintomas',
        'cramps': 'Cólicas',
        'bloating': 'Inchaço',
        'headache': 'Dor de cabeça',
        'backPain': 'Dor nas costas',
        'breastTenderness': 'Sensibilidade nos seios',
        'fatigue': 'Fadiga',
        'moodSwings': 'Mudanças de humor',
        'acne': 'Acne',
        'nausea': 'Náusea',
        'cravings': 'Desejos',
        'insomnia': 'Insônia',
        'hotFlashes': 'Ondas de calor',
        'coldFlashes': 'Calafrios',
        'diarrhea': 'Diarreia',
        'constipation': 'Constipação',
        'mood': 'Humor',
        'energy': 'Energia',
        'pain': 'Dor',
        'moodHappy': 'Feliz',
        'moodNeutral': 'Neutro',
        'moodSad': 'Triste',
        'moodAnxious': 'Ansiosa',
        'moodIrritated': 'Irritada',
        'energyHigh': 'Alta Energia',
        'energyMedium': 'Energia Média',
        'energyLow': 'Baixa Energia',
        'painNone': 'Sem Dor',
        'painMild': 'Dor Leve',
        'painModerate': 'Dor Moderada',
        'painSevere': 'Dor Severa',
        'predictions': 'Previsões',
        'nextPeriod': 'Próximo Período',
        'nextOvulation': 'Próxima Ovulação',
        'save': 'Salvar',
        'cancel': 'Cancelar',
        'delete': 'Deletar',
        'edit': 'Editar',
        'update': 'Atualizar',
        'yes': 'Sim',
        'no': 'Não',
        'ok': 'OK',
        'close': 'Fechar'
    }
}

def load_arb_file(file_path):
    """Load ARB file and return JSON data."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading {file_path}: {e}")
        return None

def save_arb_file(file_path, data):
    """Save data to ARB file with proper formatting."""
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2, separators=(',', ': '))
        print(f"Successfully updated {file_path}")
        return True
    except Exception as e:
        print(f"Error saving {file_path}: {e}")
        return False

def complete_translations():
    """Complete missing translations for key languages."""
    l10n_dir = Path(__file__).parent.parent / 'lib' / 'l10n'
    english_file = l10n_dir / 'app_en.arb'
    
    if not english_file.exists():
        print(f"English template file not found: {english_file}")
        return False
    
    # Load English template
    english_data = load_arb_file(english_file)
    if not english_data:
        return False
    
    print(f"English template loaded with {len(english_data)} keys")
    
    # Complete translations for key languages
    completed_languages = []
    
    for lang_code, translations in TRANSLATIONS.items():
        lang_file = l10n_dir / f'app_{lang_code}.arb'
        
        if not lang_file.exists():
            print(f"Language file not found: {lang_file}")
            continue
        
        # Load existing translations
        lang_data = load_arb_file(lang_file)
        if not lang_data:
            continue
        
        print(f"Processing {lang_code}...")
        
        # Count existing keys (excluding metadata)
        existing_keys = {k for k in lang_data.keys() if not k.startswith('@') and not k.startswith('@@')}
        english_keys = {k for k in english_data.keys() if not k.startswith('@') and not k.startswith('@@')}
        
        print(f"  Existing keys: {len(existing_keys)}")
        print(f"  Total needed: {len(english_keys)}")
        print(f"  Missing: {len(english_keys - existing_keys)}")
        
        # Add missing translations
        added_count = 0
        for key, value in translations.items():
            if key in english_data and key not in lang_data:
                lang_data[key] = value
                # Also add description if it exists in English
                desc_key = f"@{key}"
                if desc_key in english_data:
                    lang_data[desc_key] = english_data[desc_key]
                added_count += 1
        
        print(f"  Added {added_count} new translations")
        
        # Save updated file
        if save_arb_file(lang_file, lang_data):
            completed_languages.append(lang_code)
    
    print(f"\nCompleted translations for: {', '.join(completed_languages)}")
    return True

if __name__ == '__main__':
    complete_translations()
