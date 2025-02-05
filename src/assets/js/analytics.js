
function generateViewsPerCountryTable(data) {
    const container = document.getElementById('requests-per-country');
    const table = document.createElement('table');

    // Add a class to the table
    table.className = 'charts-css pie show-heading'; // Updated class name

    const legend = document.createElement('ul');
    legend.className = "charts-css legend legend-circle legend-inline"

    // Add caption to the table
    const caption_head = document.createElement('caption');
    caption_head.textContent = 'Requests by country';
    table.appendChild(caption_head);

    const caption_data_lifetime = document.createElement('caption');
    caption_data_lifetime.textContent = '(last 30 days)';
    table.appendChild(caption_data_lifetime);

    const thead = document.createElement('thead');
    const headerRow = document.createElement('tr');

    // Create table headers
    const headers = ['Country', 'Views'];
    headers.forEach(headerText => {
        const header = document.createElement('th');
        header.setAttribute('scope', 'col');
        header.textContent = headerText;
        headerRow.appendChild(header);
    });
    thead.appendChild(headerRow);
    table.appendChild(thead);

    // Calculate the maximum views
    const maxViews = Math.max(...data.map(item => item.views));

    // Calculate total views for pie chart
    const totalViews = data.reduce((sum, item) => sum + item.views, 0);

    // Create table body
    const tbody = document.createElement('tbody');
    let cumulativePercentage = 0; // To track the cumulative percentage for pie chart

    data.forEach(item => {
        const row = document.createElement('tr');
        const countryCell = document.createElement('th');
        const viewsCell = document.createElement('td');
        const legendItem = document.createElement('li')

        countryCell.setAttribute('scope', 'row');
        // Calculate the percentage size for bar graph
        const percentageSize = maxViews > 0 ? (item.views / maxViews) : 0;
        viewsCell.style.setProperty('--size', percentageSize.toFixed(2)); // Set the --size property

        // Calculate start and end for pie chart
        const start = cumulativePercentage;
        const end = cumulativePercentage + (totalViews > 0 ? (item.views / totalViews) : 0);
        viewsCell.style.setProperty('--start', start.toFixed(2)); // Set the --start property
        viewsCell.style.setProperty('--end', end.toFixed(2)); // Set the --end property

        legendItem.textContent = item.country || 'N/A';
        countryCell.textContent = item.country || 'N/A'; // Handle empty country
        cumulativePercentage = end; // Update cumulative percentage

        // Only add the country value if the size is greater than 0.02
        if (percentageSize > 0.1) {
            viewsCell.innerHTML = `<span class="data">${item.country || 'N/A'}</span>`; // Add the views count
        }

        row.appendChild(countryCell);
        row.appendChild(viewsCell);
        tbody.appendChild(row);

        legend.appendChild(legendItem);
    });

    table.appendChild(tbody);
    container.appendChild(table);
    container.appendChild(legend);
}

function generateViewsFromTwitterTable(data) {
	const container = document.getElementById('twitter-view-count');
    if (data.length > 0) {
        container.innerHTML = data[0].views;
    }
}

function generateViewedPagesTable(data) {
    const container = document.getElementById('views-per-page');
    const table = document.createElement('table');

    // Add a class to the table
    table.className = 'charts-css bar hide-data'; // Updated class name

    const thead = document.createElement('thead');
    const headerRow = document.createElement('tr');

    // Create table headers
    const headers = ['Page URL', 'Views'];
    headers.forEach(headerText => {
        const header = document.createElement('th');
        header.setAttribute('scope', 'col');
        header.textContent = headerText;
        headerRow.appendChild(header);
    });
    thead.appendChild(headerRow);
    table.appendChild(thead);

    // Calculate the maximum views
    const maxViews = Math.max(...data.map(item => item.views));

    // Create table body
    const tbody = document.createElement('tbody');

	const pageLabelContainer = document.getElementById('views-page-label');
    data.forEach(item => {
        const row = document.createElement('tr');
        const pageCell = document.createElement('th');
        const viewsCell = document.createElement('td');

		pageCell.setAttribute('scope', 'row');
		pageCell.textContent = item.page_url.replace('tauraamui.website', '');

        // Calculate the percentage size for bar graph
        const percentageSize = maxViews > 0 ? (item.views / maxViews) : 0;
        viewsCell.style.setProperty('--size', percentageSize.toFixed(2)); // Set the --size property
        if (percentageSize.toFixed(2) > 0.00) {
	        const dataSpan = document.createElement('span');
	        dataSpan.className = 'data';
	        dataSpan.innerHTML = item.page_url.replace('tauraamui.website', '');
	        viewsCell.appendChild(dataSpan);

			row.appendChild(pageCell);
			row.appendChild(viewsCell);
			tbody.appendChild(row);
        }


		if (percentageSize.toFixed(2) > 0.00) {
			const pageLabelSpan = document.createElement('span');
			pageLabelSpan.title = item.page_url.replace("tauraamui.website", "");
			pageLabelSpan.innerHTML = pageLabelSpan.title;
			pageLabelSpan.title += " (" + item.views + ")";
			pageLabelContainer.appendChild(pageLabelSpan);
		}
    });

	table.appendChild(tbody);
	container.appendChild(table);
}

function generateViewsPerDayTable(data) {
    const styles = document.createElement('style');
    styles.innerHTML = '#views-per-day .column { --labels-size: 4rem; }'
	const container = document.getElementById('views-per-day');
    container.appendChild(styles);
	const table = document.createElement('table');

	// assign table to represent column graph
	table.className = 'charts-css column show-labels';

	const thead = document.createElement('thead');
	const headerRow = document.createElement('tr');

	// create headers
	const headers = ['Total Views', 'Date'];
	headers.forEach(headerText => {
		const header = document.createElement('th');
		header.setAttribute('scope', 'col');
		header.textContent = headerText;
		headerRow.appendChild(header);
	});
	thead.appendChild(headerRow);
	table.appendChild(thead);

    // Calculate the maximum views
    const maxViews = Math.max(...data.map(item => item.views));

    const tbody = document.createElement('tbody');
    const monthNames = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
    data = data.map(item => {
        const [year, month, day] = item.e_date.split('.').map(Number);
        // Adjust the year to be four digits
        const fullYear = year < 50 ? 2000 + year : 1900 + year;
        const dateObj = new Date(fullYear, month - 1, day); // month is 0-indexed

        return {
          ...item,
          e_date: dateObj // Store the formatted date string
        };
    });
    data = data.sort((a, b) => a.e_date - b.e_date);
    data.forEach(item => {
        const row = document.createElement('tr');

        const th = document.createElement('th');
        th.scope = 'row';
        const dateObj = item.e_date;
        // Format the date as "DD / MMM\nYYYY"
        var formattedDate = `${String(dateObj.getDate()).padStart(2, '0')} ${monthNames[dateObj.getMonth()]}`;
        formattedDate += `\n${dateObj.getFullYear()}`;
        th.innerHTML = formattedDate;



        row.appendChild(th);

        const td  = document.createElement('td');
        const percentageSize = maxViews > 0 ? (item.views / maxViews) : 0;
        td.style.setProperty('--size', percentageSize.toFixed(2));
        const dataSpan = document.createElement('span');
        dataSpan.className = 'data';
        dataSpan.innerHTML = item.views;
        td.appendChild(dataSpan);

        row.appendChild(td);

        tbody.appendChild(row);
    })

    table.appendChild(tbody);
	container.appendChild(table);
}


document.addEventListener("DOMContentLoaded", function() {
    const base64Data = document.getElementById('jsonData').textContent;
    const jsonData = atob(base64Data); // Decode Base64
    const data = JSON.parse(jsonData); // Parse JSON

    const views_per_country_query = `
        SELECT
            country,
            COUNT(*) as views
        FROM ?
        WHERE
            country NOT LIKE ''
        GROUP BY country
        ORDER BY views DESC
    `;
    generateViewsPerCountryTable(alasql(views_per_country_query, [data]));

    const most_viewed_pages_query = `
        SELECT
            page_url,
            COUNT(*) as views
        FROM ?
        WHERE
            page_url LIKE '%tauraamui.website%'
        GROUP BY page_url
        ORDER BY views DESC
    `
    generateViewedPagesTable(alasql(most_viewed_pages_query, [data]));

	const views_from_twitter_short_links = `
		SELECT
			COUNT(*) as views
		FROM ?
		WHERE
			referrer_url LIKE 'https://t.co/%'
	`;
    generateViewsFromTwitterTable(alasql(views_from_twitter_short_links, [data]));

	const total_views_per_day = `
        SELECT
            DATE(event_timestamp)::date as e_date,
            COUNT(*) as views
        FROM ?
        WHERE
            event_type = 'page_view'
        GROUP BY DATE(event_timestamp)::date
        ORDER BY DATE(event_timestamp)::date
    `;
	generateViewsPerDayTable(alasql(total_views_per_day, [data]));
});
