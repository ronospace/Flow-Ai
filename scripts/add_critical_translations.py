#!/usr/bin/env python3
"""
Add critical missing translations to key languages.
"""
import json
import os
from pathlib import Path

# Critical translations for top priority keys
CRITICAL_TRANSLATIONS = {
    'de': {
        'trackingScreenTitle': 'Verfolgungsbildschirm',
        'flowTab': 'Fluss',
        'symptomsTab': 'Symptome',
        'moodTab': 'Stimmung',
        'painTab': 'Schmerz',
        'notesTab': 'Notizen',
        'save': 'Speichern',
        'cancel': 'Abbrechen',
        'yes': 'Ja',
        'no': 'Nein',
        'overview': 'Übersicht',
        'metrics': 'Metriken',
        'sync': 'Synchronisieren',
        'light': 'Hell',
        'dark': 'Dunkel',
        'system': 'System',
        'biometricDashboard': 'Biometrisches Dashboard',
        'aiPrediction': 'KI-Vorhersage',
        'currentCycle': 'Aktueller Zyklus',
        'noActiveCycle': 'Kein aktiver Zyklus',
        'startTracking': 'Verfolgung starten'
    },
    'es': {
        'trackingScreenTitle': 'Pantalla de Seguimiento',
        'flowTab': 'Flujo',
        'symptomsTab': 'Síntomas',
        'moodTab': 'Estado de Ánimo',
        'painTab': 'Dolor',
        'notesTab': 'Notas',
        'save': 'Guardar',
        'cancel': 'Cancelar',
        'yes': 'Sí',
        'no': 'No',
        'overview': 'Resumen',
        'metrics': 'Métricas',
        'sync': 'Sincronizar',
        'light': 'Claro',
        'dark': 'Oscuro',
        'system': 'Sistema',
        'biometricDashboard': 'Panel Biométrico',
        'aiPrediction': 'Predicción IA',
        'currentCycle': 'Ciclo Actual',
        'noActiveCycle': 'Sin ciclo activo',
        'startTracking': 'Comenzar seguimiento'
    },
    'fr': {
        'trackingScreenTitle': 'Écran de Suivi',
        'flowTab': 'Flux',
        'symptomsTab': 'Symptômes',
        'moodTab': 'Humeur',
        'painTab': 'Douleur',
        'notesTab': 'Notes',
        'save': 'Enregistrer',
        'cancel': 'Annuler',
        'yes': 'Oui',
        'no': 'Non',
        'overview': 'Vue d\'ensemble',
        'metrics': 'Métriques',
        'sync': 'Synchroniser',
        'light': 'Clair',
        'dark': 'Sombre',
        'system': 'Système',
        'biometricDashboard': 'Tableau de Bord Biométrique',
        'aiPrediction': 'Prédiction IA',
        'currentCycle': 'Cycle Actuel',
        'noActiveCycle': 'Aucun cycle actif',
        'startTracking': 'Commencer le suivi'
    },
    'it': {
        'trackingScreenTitle': 'Schermata di Tracciamento',
        'flowTab': 'Flusso',
        'symptomsTab': 'Sintomi',
        'moodTab': 'Umore',
        'painTab': 'Dolore',
        'notesTab': 'Note',
        'save': 'Salva',
        'cancel': 'Annulla',
        'yes': 'Sì',
        'no': 'No',
        'overview': 'Panoramica',
        'metrics': 'Metriche',
        'sync': 'Sincronizza',
        'light': 'Chiaro',
        'dark': 'Scuro',
        'system': 'Sistema',
        'biometricDashboard': 'Dashboard Biometrico',
        'aiPrediction': 'Previsione IA',
        'currentCycle': 'Ciclo Attuale',
        'noActiveCycle': 'Nessun ciclo attivo',
        'startTracking': 'Inizia tracciamento'
    },
    'pt': {
        'trackingScreenTitle': 'Tela de Rastreamento',
        'flowTab': 'Fluxo',
        'symptomsTab': 'Sintomas',
        'moodTab': 'Humor',
        'painTab': 'Dor',
        'notesTab': 'Notas',
        'save': 'Salvar',
        'cancel': 'Cancelar',
        'yes': 'Sim',
        'no': 'Não',
        'overview': 'Visão Geral',
        'metrics': 'Métricas',
        'sync': 'Sincronizar',
        'light': 'Claro',
        'dark': 'Escuro',
        'system': 'Sistema',
        'biometricDashboard': 'Painel Biométrico',
        'aiPrediction': 'Previsão IA',
        'currentCycle': 'Ciclo Atual',
        'noActiveCycle': 'Nenhum ciclo ativo',
        'startTracking': 'Iniciar rastreamento'
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

def add_critical_translations():
    """Add critical translations to key languages."""
    l10n_dir = Path(__file__).parent.parent / 'lib' / 'l10n'
    
    for lang_code, translations in CRITICAL_TRANSLATIONS.items():
        lang_file = l10n_dir / f'app_{lang_code}.arb'
        
        if not lang_file.exists():
            print(f"Language file not found: {lang_file}")
            continue
        
        # Load existing translations
        lang_data = load_arb_file(lang_file)
        if not lang_data:
            continue
        
        print(f"Adding critical translations for {lang_code}...")
        
        # Add missing critical translations
        added_count = 0
        for key, value in translations.items():
            if key not in lang_data:
                lang_data[key] = value
                added_count += 1
        
        print(f"  Added {added_count} critical translations")
        
        # Save updated file
        save_arb_file(lang_file, lang_data)
    
    print("Critical translations completed!")
    return True

if __name__ == '__main__':
    add_critical_translations()
