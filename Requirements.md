# Requirements

## All Screens

* Display a menu button, that when pressed, display a [Navigation Drawer](#navigation-drawer).

## Home Screen

* Display **application name**.
* Display all **shopping lists** in a list.
* Navigate to appropriate [Shopping List Screen](#shopping-list-screen) when a **shopping list** is pressed.
* Display a **floating button** that when pressed display a **shopping list addition card**, that allows the **user** to add a new **shopping list**.

## Shopping List Screen

* Display **shopping list name**.
* Display an **action list** that includes:
  * **Delete**: deletes **shopping list**.
* Display [Shopping Items](#shopping-item) inside corresponding [Collections](#collection).
* Display a **floating button** that when pressed display a **shopping item addition card**, that allows the **user** to add a new **shopping item**. Adds **shopping item** under a **collection** if any of the **collections** in storage have a **shopping item** with the same name (NOT case sensitive), else, adds **shopping item** to **Others**.

### Shopping Item

* Display **item name**.
* Display whether **item** is **checked**.
* Display an **action list** that includes:
  * **Change Collection**: Display a **Collection Change Card** that:
    * changes the **collection** for which each **shopping item** with the same **name (NOT case sensitive)** belongs to.
    * Allows the **user** to add the **shopping item** to a new collection.
  * **Delete**: Deletes **shopping item**.
* Deletes **shopping item** when swiped left or right.

### Collection

* Can be retractable.
* Display an **action list** that includes:
  * **Change Name**: Changes **collection** name across all **shopping lists**.
  * **Remove**: Remove all [Shopping Items](#shopping-item) inside it from [Shopping List Screen](#shopping-list-screen) (Does not delete **collection** from storage).

## Collections Screen

* Display all **collections** in storage.
* Display shopping item names for each **collection**. Each of those names can be removed.
* Display an **action list** that includes:
  * **Add**: Add a new **shopping item name** to **collection**
  * **Rename**: Renames **collection**.
  * **Delete**: Deletes **collection**.
* Each **collection** is retractable.
* Display a **floating button** that when pressed displays **Collection Addition Card** that allows the **user** to add a new **collection**.

## Navigation Drawer

* Display links leading to:
  * [Home Screen](#home-screen)
  * [Collections Screen](#collections-screen)
  * [About](#about).
  * **Source Code**, which launches the application's directory at GitHub using the **user**'s default browser.

## About

* Display relevant information.
