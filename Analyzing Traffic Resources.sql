-- Main Objective (1): Finding top traffic sources

-- Task: An Email was sent on April 12-2012 from the CEO: Cindy Sharp and it includes the following:

-- We've been live for almost a month now and we’re starting to generate sales. Can you help me understand where the bulk of our website sessions are coming from, through yesterday?
-- I’d like to see a breakdown by UTM source , campaign and referring domain if possible. Thanks!

-- Personal Hint: Always Start the query with the WHERE condition first so you dont forget it and your results match the outcomes the business stakeholders are expecting

SELECT
utm_source,
utm_campaign,
http_referer,
COUNT(distinct website_session_id) as Number_of_Sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY 1,2,3 -- 1 indicates first column called (utm_source), 2 indicates second column called (utm_campaign), 3 indicates thrid column called (http_referer) and 4 indicates fourth column called (Number of Sessions)
ORDER BY 4 DESC;
-- Conclusion to Objective (1):
-- The gsearch nonbrand had the highest amount of sessions. We should dig deeper into it for further analysis.

-- -----------------------------------------------------------------------------------------------------------------------------

-- Main Objective (2): Calculate traffic conversion rates

-- Task: An Email was sent on April 14-2012 from the Marketing Director: Tom Parmesan and it includes the following:

-- Sounds like gsearch nonbrand is our major traffic source, but we need to understand if those sessions are driving sales.
-- Could you please calculate the conversion rate (CVR) from session to order ?
-- Based on what we're paying for clicks, we’ll need a CVR of at least 4% to make the numbers work. If we're much lower, we’ll need to reduce bids. If we’re higher, we can increase bids to drive more volume

SELECT
utm_source,
utm_campaign,
COUNT(distinct website_sessions.website_session_id) AS Number_of_Sessions,
COUNT(distinct orders.order_id) AS Number_of_Orders,
COUNT(distinct orders.order_id)/ COUNT(distinct website_sessions.website_session_id) AS CVR
from website_sessions
left join orders
on website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.created_at < '2012-04-14'
AND utm_source='gsearch'
AND utm_campaign= 'nonbrand';
-- Conclusion to Objective (2):
-- The Conversion rate from sessions to orders is less than the threshold of 4 % specified by the Marketing Director. Thus, The next step should be bidding down the gsearch nonbrand

-- -----------------------------------------------------------------------------------------------------------------------------

-- Main Objective (3): Find Traffic Source Trending

-- Task: An Email was sent on May 10-2012 from the Marketing Director: Tom Parmesan and it includes the following:

-- Based on your conversion rate analysis, we bid down gsearch nonbrand on 2012 04 15.
-- Can you pull gsearch nonbrand trended session volume, by week , to see if the bid changes have caused volume to drop at all?

SELECT
-- Year(created_at) AS Year,
-- Week(created_at) AS Week,
MIN(DATE(created_at)) AS Start_of_Week, -- Bring the full date of the selected year & week
COUNT(distinct website_session_id) AS Number_of_Sessions
from website_sessions
WHERE website_sessions.created_at < '2012-05-10'
AND utm_source='gsearch'
AND utm_campaign= 'nonbrand'
GROUP BY 
Year(created_at), -- You can GROUP BY something that does not exist in your SELECT statement "Commented Out"
Week(created_at); -- You can GROUP BY something that does not exist in your SELECT statement "Commented Out"
-- Conclusion to Objective (3):
-- Testing the impact of decreasing the bid for the gsearch nonbrand has shown a reduction in the number of its sessions as expected after the bid down on 15th of May 2012 
-- During the next step We should think about increasing the number of sessions again but in a more efficient way

-- -----------------------------------------------------------------------------------------------------------------------------

-- Main Objective (4): Traffic Source Bid Optimization

-- Task: An Email was sent on May 11-2012 from the Marketing Director: Tom Parmesan and it includes the following:

-- I was trying to use our site on my mobile device the other day, and the experience was not great.
-- Could you pull conversion rates from session to order , by device type ? 
-- If desktop performance is better than on mobile we may be able to bid up for desktop specifically to get more volume?

SELECT
device_type,
COUNT(DISTINCT website_sessions.website_session_id) as Number_of_Sessions,
COUNT(DISTINCT orders.order_id) as Number_of_Orders,
COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) as CVR
FROM website_sessions
LEFT JOIN Orders
ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.created_at < '2012-05-11'
AND utm_source='gsearch'
AND utm_campaign= 'nonbrand'
GROUP BY 1;
-- Conclusion to Objective (4):
-- desktop conversion rates are higher than mobile. Thus, increasing the bids on the desktop is the logical next step

-- -----------------------------------------------------------------------------------------------------------------------------

-- Main Objective (5): Traffic Source Segment Trending

-- Task: An Email was sent on June 09-2012 from the Marketing Director: Tom Parmesan and it includes the following:

-- After your device level analysis of conversion rates, we realized desktop was doing well, so we bid our gsearch nonbrand desktop campaigns up on 2012-05-19.
-- Could you pull weekly trends for both desktop and mobile so we can see the impact on volume?
-- You can use 2012-04-15 until the bid change as a baseline.

SELECT
-- YEAR(created_at),
-- WEEK(created_at),
MIN(DATE(created_at)) AS Start_of_Week,
COUNT(DISTINCT website_session_id) AS Total_Number_of_Sessions,
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions, -- PIVOTING Data into columns like EXCLE Pivot Table
COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions -- PIVOTING Data into columns like EXCLE Pivot Table
FROM website_sessions
WHERE created_at BETWEEN '2012-04-15' AND '2012-06-09'
AND utm_source='gsearch'
AND utm_campaign= 'nonbrand'
GROUP by 
YEAR(created_at),
WEEK(created_at);
-- Conclusion to Objective (5):
-- Testing the impact of increasing the bids for desktop has shown that the desktop sessions are increasing as expected after the gsearch nonbrand desktop campaign conducted on 19th of May 2012

-- -----------------------------------------------------------------------------------------------------------------------------
