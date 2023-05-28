```plantuml
@startuml
title Core Loop for Mercenary Simulator

[*] --> Main Menu

Main Menu --> Mission Select
Main Menu --> Mercenary Roster
Main Menu --> Faction Network

Mission Select --> Combat
Mission Select --> Unit Management

Unit Management --> Skills and Traits
Unit Management --> Equipment
Unit Management --> Roster

Combat --> Victory or Defeat
Combat --> Loot and Rewards

Victory or Defeat --> Mission Select

Loot and Rewards --> Mercenary Roster

Faction Network --> Diplomacy
Faction Network --> Alliance Building
Faction Network --> Information Gathering

Diplomacy --> Faction Network
Alliance Building --> Faction Network
Information Gathering --> Faction Network

@enduml```