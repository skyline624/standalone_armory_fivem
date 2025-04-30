// html/script.js
document.addEventListener('DOMContentLoaded', () => {
    const menu = document.getElementById('armory-menu');
    const itemList = document.getElementById('item-list');
    const closeButton = document.getElementById('close-button');
    let currentItems = []; // To store received items
    let isBuying = false; // Debounce variable
    const debounceTime = 1500; // Time in milliseconds (1.5 seconds)

    // Function to display the menu and populate the list
    function displayMenu(items) {
        itemList.innerHTML = ''; // Clear previous list
        currentItems = items; // Save items

        items.forEach((item, index) => {
            const itemDiv = document.createElement('div');
            itemDiv.classList.add('item');

            const nameSpan = document.createElement('span');
            nameSpan.classList.add('item-name');
            nameSpan.textContent = item.name;

            const priceSpan = document.createElement('span');
            priceSpan.classList.add('item-price');
            priceSpan.textContent = `$${item.price}`; // Display price

            const buyButton = document.createElement('button');
            buyButton.classList.add('buy-button');
            buyButton.textContent = 'Buy'; // Translated button text
            buyButton.dataset.itemIndex = index; // Store original item index

            buyButton.addEventListener('click', () => {
                // --- DEBOUNCE CHECK --- 
                if (isBuying) {
                    console.log("Purchase already in progress or button on cooldown."); // Translated log
                    return; // Do nothing if a purchase is already in progress
                }
                isBuying = true; // Mark that a purchase is starting
                buyButton.disabled = true; // Visually disable the button
                buyButton.textContent = '...'; // Change text (optional)
                // ----------------------

                // Send the item index to the Lua script via NUI
                fetch(`https://${GetParentResourceName()}/buyItem`, { // Important: Use https and the resource name
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: JSON.stringify({ itemIndex: index }) // Send index
                }).then(resp => resp.json()).then(resp => {
                    // console.log('Buy response:', resp); // For debugging
                }).catch(error => {
                    console.error("Error sending purchase request:", error); // Translated log
                }).finally(() => {
                    // --- RESET DEBOUNCE --- 
                    // Re-enable the button after a delay, whether purchase succeeded or failed
                    setTimeout(() => {
                        isBuying = false;
                        // Check if the button still exists (menu might be closed)
                        if (buyButton) {
                           buyButton.disabled = false;
                           buyButton.textContent = 'Buy'; // Translated button text
                        }
                    }, debounceTime);
                    // ----------------------
                });
            });

            itemDiv.appendChild(nameSpan);
            itemDiv.appendChild(priceSpan);
            itemDiv.appendChild(buyButton);
            itemList.appendChild(itemDiv);
        });

        menu.style.display = 'flex'; // Show the menu
    }

    // Function to hide the menu
    function closeMenu() {
        menu.style.display = 'none';
        itemList.innerHTML = ''; // Clear list on close
        currentItems = [];
        isBuying = false; // Reset debounce if menu is closed
    }

    // Listen for messages from the Lua script
    window.addEventListener('message', (event) => {
        const data = event.data;

        if (data.action === 'open') {
            isBuying = false; // Ensure debounce is reset on open
            displayMenu(data.items);
        } else if (data.action === 'close') {
            closeMenu();
        }
    });

    // Handle click on the Close button
    closeButton.addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/closeMenu`, { // Notify Lua that the menu is closed
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).then(resp => resp.json()).then(resp => {
            // console.log('Close response:', resp); // Debugging
        }).catch(error => {
            console.error("Error sending close request:", error); // Translated log
        });
    });

    // Handle Escape key to close (alternative)
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
            // Notify Lua to close the menu
            fetch(`https://${GetParentResourceName()}/closeMenu`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            }).catch(error => console.error("Escape key error:", error)); // Translated log
        }
    });

    // Utility function to get the parent resource name (needed for NUI fetch)
    // Note: This function might not be available in all NUI contexts.
    // If it causes issues, replace GetParentResourceName() with the exact name of your resource (e.g., 'commerce_arme')
    function GetParentResourceName() {
        // Attempt to retrieve via NUI API (if available)
        if (window.GetParentResourceName) {
            return window.GetParentResourceName();
        }
        // Otherwise, try to guess from the URL (less reliable)
        const resourceNameMatch = window.location.pathname.match(/([^\/]+)\/html\/index.html/);
        if (resourceNameMatch && resourceNameMatch[1]) {
            return resourceNameMatch[1];
        }
        // As a last resort, hardcode your resource name here
        return 'commerce_arme'; // Replace if necessary
    }
});