-- Seasonal movie windows for 2026 (hand-curated).
--
-- This is a dbt-native replacement for manually inserting into PUBLIC.seasonal_movie_windows_2026.
-- Grain: one row per window with arrays of popular genres and description keywords.

with windows as (

    select
        start_date,
        until_date,
        period_description,
        parse_json(popular_genre_json)         as popular_genre,
        parse_json(description_keywords_json)  as description_keywords
    from (
        values
            ('2026-01-01'::date, '2026-01-06'::date, 'New Year and first week of January',
                '[\"comedy\",\"family\",\"drama\"]',
                '[\"new year\",\"fresh start\",\"second chance\",\"celebration\",\"hope\",\"reunion\",\"self-discovery\"]'),
            ('2026-01-07'::date, '2026-02-13'::date, 'Deep winter / indoor season before Valentine''s Day',
                '[\"drama\",\"history\",\"thriller\"]',
                '[\"based on true story\",\"biography\",\"ambition\",\"grief\",\"courtroom\",\"investigation\",\"award-winning\"]'),
            ('2026-02-14'::date, '2026-02-17'::date, 'Valentine''s and Carnival window',
                '[\"romance\",\"comedy\",\"drama\",\"music\"]',
                '[\"love\",\"couple\",\"dating\",\"wedding\",\"soulmate\",\"breakup\",\"passion\",\"party\"]'),
            ('2026-02-18'::date, '2026-03-19'::date, 'Late winter / pre-spring transition',
                '[\"action\",\"drama\",\"thriller\"]',
                '[\"journey\",\"transition\",\"self-discovery\",\"road trip\",\"survival\",\"finding purpose\"]'),
            ('2026-03-20'::date, '2026-04-02'::date, 'Spring arrival and Easter lead-in',
                '[\"family\",\"fantasy\",\"action\",\"drama\"]',
                '[\"spring\",\"growth\",\"renewal\",\"magic\",\"blossom\",\"journey\",\"rebirth\",\"new beginnings\"]'),
            ('2026-04-03'::date, '2026-04-06'::date, 'Easter weekend / long holiday window',
                '[\"family\",\"animation\",\"drama\"]',
                '[\"easter\",\"resurrection\",\"faith\",\"miracle\",\"forgiveness\",\"family\",\"hope\",\"renewal\"]'),
            ('2026-04-07'::date, '2026-05-07'::date, 'Post-Easter spring family window',
                '[\"family\",\"comedy\",\"fantasy\",\"documentation\"]',
                '[\"garden\",\"animals\",\"spring break\",\"outdoors\",\"friendship\",\"growth\",\"family trip\"]'),
            ('2026-05-08'::date, '2026-05-10'::date, 'Mother''s Day weekend',
                '[\"family\",\"drama\",\"comedy\"]',
                '[\"mother\",\"family\",\"homecoming\",\"reunion\",\"parent\",\"sacrifice\",\"generations\",\"healing\"]'),
            ('2026-05-11'::date, '2026-05-21'::date, 'Pre-summer crowd-pleaser window',
                '[\"action\",\"family\",\"comedy\",\"fantasy\"]',
                '[\"quest\",\"friendship\",\"school break\",\"road trip\",\"treasure\",\"summer plans\"]'),
            ('2026-05-22'::date, '2026-05-25'::date, 'Memorial Day weekend / summer box-office kickoff',
                '[\"action\",\"scifi\",\"fantasy\",\"thriller\"]',
                '[\"mission\",\"invasion\",\"hero\",\"explosion\",\"franchise\",\"spectacle\",\"survival\",\"battle\"]'),
            ('2026-05-26'::date, '2026-06-20'::date, 'Early summer and Pride Month opening',
                '[\"romance\",\"drama\",\"comedy\",\"music\"]',
                '[\"identity\",\"self-acceptance\",\"chosen family\",\"queer\",\"love story\",\"coming out\",\"community\"]'),
            ('2026-06-21'::date, '2026-07-05'::date, 'Summer solstice and Independence Day corridor',
                '[\"action\",\"animation\",\"family\",\"thriller\"]',
                '[\"summer\",\"beach\",\"fireworks\",\"independence\",\"america\",\"military\",\"island\",\"vacation\"]'),
            ('2026-07-06'::date, '2026-08-16'::date, 'Peak summer vacation season',
                '[\"action\",\"animation\",\"comedy\",\"family\",\"fantasy\"]',
                '[\"vacation\",\"road trip\",\"beach\",\"camp\",\"island\",\"heist\",\"treasure\",\"getaway\",\"summer\"]'),
            ('2026-08-17'::date, '2026-09-07'::date, 'Back-to-school and Labor Day window',
                '[\"comedy\",\"drama\",\"sport\",\"horror\"]',
                '[\"school\",\"college\",\"teacher\",\"team\",\"freshman\",\"friendship\",\"locker\",\"semester\",\"tryouts\"]'),
            ('2026-09-08'::date, '2026-10-15'::date, 'Early autumn / cozy season',
                '[\"thriller\",\"fantasy\",\"drama\",\"european\"]',
                '[\"small town\",\"secrets\",\"harvest\",\"cottage\",\"bookstore\",\"detective\",\"autumn\",\"folklore\"]'),
            ('2026-10-16'::date, '2026-10-31'::date, 'Halloween season',
                '[\"horror\",\"thriller\",\"comedy\",\"fantasy\"]',
                '[\"haunted\",\"ghost\",\"witch\",\"vampire\",\"killer\",\"possession\",\"monster\",\"cursed\",\"halloween\"]'),
            ('2026-11-01'::date, '2026-11-26'::date, 'Remembrance period and Thanksgiving build-up',
                '[\"family\",\"drama\",\"comedy\",\"fantasy\"]',
                '[\"memory\",\"ancestors\",\"afterlife\",\"remembrance\",\"family legacy\",\"spirits\",\"gratitude\",\"homecoming\"]'),
            ('2026-11-27'::date, '2026-11-30'::date, 'Black Friday / winter blockbuster kickoff',
                '[\"fantasy\",\"action\",\"animation\",\"family\"]',
                '[\"sequel\",\"chosen one\",\"kingdom\",\"quest\",\"universe\",\"battle\",\"dragon\",\"spectacle\"]'),
            ('2026-12-01'::date, '2026-12-24'::date, 'Christmas build-up / Advent season',
                '[\"romance\",\"family\",\"music\",\"fantasy\"]',
                '[\"christmas\",\"holiday\",\"snow\",\"santa\",\"gift\",\"miracle\",\"festive\",\"carol\",\"winter\"]'),
            ('2026-12-25'::date, '2026-12-31'::date, 'Christmas week and year-end holiday stretch',
                '[\"action\",\"family\",\"drama\",\"fantasy\"]',
                '[\"celebration\",\"family gathering\",\"holiday break\",\"epic\",\"award contender\",\"winter escape\",\"reunion\"]')
    ) as t(start_date, until_date, period_description, popular_genre_json, description_keywords_json)

)

select *
from windows
