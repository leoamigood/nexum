SELECT to_char(visited_at, 'YYYY-MM-DD') visited_date, count(*) visited_count
FROM repositories
WHERE visited_at IS NOT NULL
GROUP BY to_char(visited_at, 'YYYY-MM-DD')


