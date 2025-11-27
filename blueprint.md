# Project Blueprint

## Overview

A comprehensive team management and match generation application designed for amateur sports enthusiasts. It allows users to manage a roster of players, create balanced teams for a match, and visualize team formations.

## Current Features & Design

### Core Data Models

*   **Player:** Represents an individual with attributes like name, surname, skill level, preferred positions, and customizable avatar details.
*   **Team:** A group of players with a designated name and color.
*   **Match:** Records a game, including the two competing teams, the match date, and the logic used for balancing.
*   **Formation:** A tactical layout of player positions on the field.

### Database & Services

*   **Cloud Firestore:** Persists all player, match, and formation data.
*   **DatabaseService:** A centralized service class that manages all interactions with Firestore.
*   **TeamBalancingService:** An intelligent service that divides players into two teams based on skill or random assignment.

### Visual Design & UI/UX

*   **Theme:** A modern, dark theme with vibrant accents.
    *   **Background:** Deep dark tones (`#111111`) for low eye strain.
    *   **Accent Colors:** Bright turquoise, orange, and neon green for a sporty, energetic feel.
    *   **Typography:** Utilizes `google_fonts` (`Oswald` for headers, `Roboto` for body text) to create a clean, sporty, and readable UI.

*   **Player Cards (`PlayerCard`):**
    *   Each player is represented by a stylish card featuring a circular avatar, their name, and a skill rating displayed as stars.
    *   Includes a prominent position tag and a clear breakdown of key attributes (Attack, Defense, Speed).

*   **Player Icons (`PlayerIcon`):**
    *   A simplified, circular representation of a player used on the formation screen, showing their jersey number or initial.

*   **Buttons:**
    *   Primary actions like "Shuffle" and "Save Match" are presented as large, bold, centered buttons for easy access and a clear user flow.

*   **Animations:**
    *   **Shuffle:** Player cards lightly jump and rearrange when teams are shuffled.
    *   **Player Entry:** New players slide smoothly into view.
    *   **Formation Changes:** Player icons animate with a soft, elastic transition when moved or when the formation is changed.

### Key Screens & Functionality

*   **Roster Management (`RosterScreen`):**
    *   Displays all players in a modern, card-based grid layout.
    *   Allows for adding and editing players.

*   **Match Generation Flow:**
    *   **Player Selection (`TeamSelectionScreen`):** Users select players for a match from a responsive grid of `PlayerCard`s.
    *   **Team Preview (`TeamBalancingScreen`):** Displays the two generated teams in clear, side-by-side columns with the prominent "Shuffle" and "Save Match" buttons.

*   **Match History (`MatchScreen`):**
    *   Displays a list of all previously saved matches using a dedicated `MatchCard` for a clean summary.

*   **Tactical Board (`FormationScreen`):**
    *   Features a drag-and-drop interface on a football pitch background.
    *   Players are represented by `PlayerIcon`s, which can be moved to create and save custom formations.

## Latest UI/UX Overhaul Summary

*   **Objective:** To implement a modern, dark, and visually engaging user interface based on a clear design vision.
*   **Key Changes:**
    *   **Theming:** Implemented a new dark theme with a vibrant accent color palette and custom Google Fonts.
    *   **Component Redesign:** Completely redesigned the `PlayerCard` and created new `PlayerIcon` and `MatchCard` widgets to align with the new aesthetic.
    *   **Screen Revamp:** Updated all major screens (`Roster`, `TeamSelection`, `TeamBalancing`, `Match`, `Formation`) to use the new theme and components, improving layout and usability.
    *   **Animations:** Added subtle animations for shuffling, player movement, and formation transitions to enhance the user experience.