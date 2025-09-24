// Sample tracking data
const trackingData = {
    'DT123456': {
        status: 'Delivered',
        statusClass: 'status-delivered',
        location: 'Customer Address',
        timestamp: '2024-09-23 14:30:00',
        updates: [
            { time: '2024-09-21 09:00:00', status: 'Package picked up', location: 'Warehouse A' },
            { time: '2024-09-21 15:30:00', status: 'In transit to sorting facility', location: 'Transit Hub' },
            { time: '2024-09-22 08:15:00', status: 'Arrived at local facility', location: 'Local Depot' },
            { time: '2024-09-22 11:45:00', status: 'Out for delivery', location: 'Delivery Vehicle' },
            { time: '2024-09-23 14:30:00', status: 'Delivered', location: 'Customer Address' }
        ]
    },
    'DT789012': {
        status: 'In Transit',
        statusClass: 'status-transit',
        location: 'Regional Hub',
        timestamp: '2024-09-24 08:15:00',
        updates: [
            { time: '2024-09-23 10:00:00', status: 'Package picked up', location: 'Warehouse B' },
            { time: '2024-09-23 16:20:00', status: 'In transit to regional hub', location: 'Transit Vehicle' },
            { time: '2024-09-24 08:15:00', status: 'Arrived at regional hub', location: 'Regional Hub' }
        ]
    },
    'DT345678': {
        status: 'Processing',
        statusClass: 'status-processing',
        location: 'Warehouse C',
        timestamp: '2024-09-24 02:10:00',
        updates: [
            { time: '2024-09-24 02:10:00', status: 'Order received', location: 'Warehouse C' },
            { time: '2024-09-24 02:10:00', status: 'Processing order', location: 'Warehouse C' }
        ]
    }
};

function trackPackage() {
    const trackingNumber = document.getElementById('trackingNumber').value.trim().toUpperCase();
    const resultsSection = document.getElementById('resultsSection');
    const trackingResults = document.getElementById('trackingResults');
    
    if (!trackingNumber) {
        alert('Please enter a tracking number');
        return;
    }
    
    // Show results section
    resultsSection.style.display = 'block';
    
    // Check if tracking number exists in our sample data
    if (trackingData[trackingNumber]) {
        const data = trackingData[trackingNumber];
        displayTrackingResults(trackingNumber, data);
    } else {
        displayNoResults(trackingNumber);
    }
    
    // Scroll to results
    resultsSection.scrollIntoView({ behavior: 'smooth' });
}

function displayTrackingResults(trackingNumber, data) {
    const trackingResults = document.getElementById('trackingResults');
    
    let updatesHtml = '';
    data.updates.forEach(update => {
        updatesHtml += `
            <div style="margin-bottom: 10px; padding-bottom: 10px; border-bottom: 1px solid #e2e8f0;">
                <strong>${update.time}</strong> - ${update.status}<br>
                <small style="color: #666;">📍 ${update.location}</small>
            </div>
        `;
    });
    
    trackingResults.innerHTML = `
        <div style="margin-bottom: 20px;">
            <h4>Tracking Number: ${trackingNumber}</h4>
            <p><strong>Current Status:</strong> <span class="${data.statusClass}">${data.status}</span></p>
            <p><strong>Current Location:</strong> ${data.location}</p>
            <p><strong>Last Update:</strong> ${data.timestamp}</p>
        </div>
        <div>
            <h5>Tracking History:</h5>
            ${updatesHtml}
        </div>
    `;
}

function displayNoResults(trackingNumber) {
    const trackingResults = document.getElementById('trackingResults');
    
    trackingResults.innerHTML = `
        <div>
            <h4>Tracking Number: ${trackingNumber}</h4>
            <p class="status-error">❌ Tracking number not found</p>
            <p>Please check your tracking number and try again.</p>
            <p><strong>Tip:</strong> Try one of the demo tracking numbers listed below.</p>
        </div>
    `;
}

// Allow enter key to trigger search
document.getElementById('trackingNumber').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        trackPackage();
    }
});

// Add some demo functionality
document.addEventListener('DOMContentLoaded', function() {
    console.log('Detrack Test App loaded successfully!');
    console.log('Try tracking numbers: DT123456, DT789012, DT345678');
});