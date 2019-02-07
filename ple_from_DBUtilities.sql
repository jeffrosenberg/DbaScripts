SELECT TOP 100 Id, CreateDate, CntrValue
FROM DBUtilities.logs.PerfmonCountersWithTypes
WHERE CounterName = 'Page life expectancy                                                                                                            '
ORDER BY id DESC