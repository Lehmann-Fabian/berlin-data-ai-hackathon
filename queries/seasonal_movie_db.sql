INSERT INTO seasonal_movie_windows_2026 (
    start_date,
    until_date,
    period_description,
    popular_genre,
    description_keywords
)
SELECT '2026-01-01'::DATE, '2026-01-06'::DATE, 'New Year and first week of January', ARRAY_CONSTRUCT('comedy', 'family', 'drama'), ARRAY_CONSTRUCT('new year', 'fresh start', 'second chance', 'celebration', 'hope', 'reunion', 'self-discovery')
UNION ALL SELECT '2026-01-07'::DATE, '2026-02-13'::DATE, 'Deep winter / indoor season before Valentine''s Day', ARRAY_CONSTRUCT('drama', 'history', 'thriller'), ARRAY_CONSTRUCT('based on true story', 'biography', 'ambition', 'grief', 'courtroom', 'investigation', 'award-winning')
UNION ALL SELECT '2026-02-14'::DATE, '2026-02-17'::DATE, 'Valentine''s and Carnival window', ARRAY_CONSTRUCT('romance', 'comedy', 'drama', 'music'), ARRAY_CONSTRUCT('love', 'couple', 'dating', 'wedding', 'soulmate', 'breakup', 'passion', 'party')
UNION ALL SELECT '2026-02-18'::DATE, '2026-03-19'::DATE, 'Late winter / pre-spring transition', ARRAY_CONSTRUCT('action', 'drama', 'thriller'), ARRAY_CONSTRUCT('journey', 'transition', 'self-discovery', 'road trip', 'survival', 'finding purpose')
UNION ALL SELECT '2026-03-20'::DATE, '2026-04-02'::DATE, 'Spring arrival and Easter lead-in', ARRAY_CONSTRUCT('family', 'fantasy', 'action', 'drama'), ARRAY_CONSTRUCT('spring', 'growth', 'renewal', 'magic', 'blossom', 'journey', 'rebirth', 'new beginnings')
UNION ALL SELECT '2026-04-03'::DATE, '2026-04-06'::DATE, 'Easter weekend / long holiday window', ARRAY_CONSTRUCT('family', 'animation', 'drama'), ARRAY_CONSTRUCT('easter', 'resurrection', 'faith', 'miracle', 'forgiveness', 'family', 'hope', 'renewal')
UNION ALL SELECT '2026-04-07'::DATE, '2026-05-07'::DATE, 'Post-Easter spring family window', ARRAY_CONSTRUCT('family', 'comedy', 'fantasy', 'documentation'), ARRAY_CONSTRUCT('garden', 'animals', 'spring break', 'outdoors', 'friendship', 'growth', 'family trip')
UNION ALL SELECT '2026-05-08'::DATE, '2026-05-10'::DATE, 'Mother''s Day weekend', ARRAY_CONSTRUCT('family', 'drama', 'comedy'), ARRAY_CONSTRUCT('mother', 'family', 'homecoming', 'reunion', 'parent', 'sacrifice', 'generations', 'healing')
UNION ALL SELECT '2026-05-11'::DATE, '2026-05-21'::DATE, 'Pre-summer crowd-pleaser window', ARRAY_CONSTRUCT('action', 'family', 'comedy', 'fantasy'), ARRAY_CONSTRUCT('quest', 'friendship', 'school break', 'road trip', 'treasure', 'summer plans')
UNION ALL SELECT '2026-05-22'::DATE, '2026-05-25'::DATE, 'Memorial Day weekend / summer box-office kickoff', ARRAY_CONSTRUCT('action', 'scifi', 'fantasy', 'thriller'), ARRAY_CONSTRUCT('mission', 'invasion', 'hero', 'explosion', 'franchise', 'spectacle', 'survival', 'battle')
UNION ALL SELECT '2026-05-26'::DATE, '2026-06-20'::DATE, 'Early summer and Pride Month opening', ARRAY_CONSTRUCT('romance', 'drama', 'comedy', 'music'), ARRAY_CONSTRUCT('identity', 'self-acceptance', 'chosen family', 'queer', 'love story', 'coming out', 'community')
UNION ALL SELECT '2026-06-21'::DATE, '2026-07-05'::DATE, 'Summer solstice and Independence Day corridor', ARRAY_CONSTRUCT('action', 'animation', 'family', 'thriller'), ARRAY_CONSTRUCT('summer', 'beach', 'fireworks', 'independence', 'america', 'military', 'island', 'vacation')
UNION ALL SELECT '2026-07-06'::DATE, '2026-08-16'::DATE, 'Peak summer vacation season', ARRAY_CONSTRUCT('action', 'animation', 'comedy', 'family', 'fantasy'), ARRAY_CONSTRUCT('vacation', 'road trip', 'beach', 'camp', 'island', 'heist', 'treasure', 'getaway', 'summer')
UNION ALL SELECT '2026-08-17'::DATE, '2026-09-07'::DATE, 'Back-to-school and Labor Day window', ARRAY_CONSTRUCT('comedy', 'drama', 'sport', 'horror'), ARRAY_CONSTRUCT('school', 'college', 'teacher', 'team', 'freshman', 'friendship', 'locker', 'semester', 'tryouts')
UNION ALL SELECT '2026-09-08'::DATE, '2026-10-15'::DATE, 'Early autumn / cozy season', ARRAY_CONSTRUCT('thriller', 'fantasy', 'drama', 'european'), ARRAY_CONSTRUCT('small town', 'secrets', 'harvest', 'cottage', 'bookstore', 'detective', 'autumn', 'folklore')
UNION ALL SELECT '2026-10-16'::DATE, '2026-10-31'::DATE, 'Halloween season', ARRAY_CONSTRUCT('horror', 'thriller', 'comedy', 'fantasy'), ARRAY_CONSTRUCT('haunted', 'ghost', 'witch', 'vampire', 'killer', 'possession', 'monster', 'cursed', 'halloween')
UNION ALL SELECT '2026-11-01'::DATE, '2026-11-26'::DATE, 'Remembrance period and Thanksgiving build-up', ARRAY_CONSTRUCT('family', 'drama', 'comedy', 'fantasy'), ARRAY_CONSTRUCT('memory', 'ancestors', 'afterlife', 'remembrance', 'family legacy', 'spirits', 'gratitude', 'homecoming')
UNION ALL SELECT '2026-11-27'::DATE, '2026-11-30'::DATE, 'Black Friday / winter blockbuster kickoff', ARRAY_CONSTRUCT('fantasy', 'action', 'animation', 'family'), ARRAY_CONSTRUCT('sequel', 'chosen one', 'kingdom', 'quest', 'universe', 'battle', 'dragon', 'spectacle')
UNION ALL SELECT '2026-12-01'::DATE, '2026-12-24'::DATE, 'Christmas build-up / Advent season', ARRAY_CONSTRUCT('romance', 'family', 'music', 'fantasy'), ARRAY_CONSTRUCT('christmas', 'holiday', 'snow', 'santa', 'gift', 'miracle', 'festive', 'carol', 'winter')
UNION ALL SELECT '2026-12-25'::DATE, '2026-12-31'::DATE, 'Christmas week and year-end holiday stretch', ARRAY_CONSTRUCT('action', 'family', 'drama', 'fantasy'), ARRAY_CONSTRUCT('celebration', 'family gathering', 'holiday break', 'epic', 'award contender', 'winter escape', 'reunion');
