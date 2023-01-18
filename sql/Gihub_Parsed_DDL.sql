
--CREATE VIEW [dbo].[GithubResultsParsed]
--as
SELECT	SUBSTRING(queryContext, (PATINDEX('% site:%',queryContext)+6),(PATINDEX('%.com%',queryContext)-(PATINDEX('% site:%',queryContext)+6))) + '-'+ _type as AssetType,
		SUBSTRING(queryContext, (PATINDEX('%originalQuery":"%',queryContext)+16), (PATINDEX('% site:%',queryContext)-PATINDEX('%originalQuery":"%',queryContext)-16)) as SearchTerm,
		*
FROM	OPENROWSET(	PROVIDER = 'CosmosDB',
					CONNECTION = N'account=cdb-bs;database=BingSearch_Results;region=;',
					OBJECT = N'Youtube',
					SERVER_CREDENTIAL = N'CosmosDB_cdb-bs'
				)  
			WITH (	readLink varchar(8000),
					_rid varchar(8000),
					_etag varchar(8000),
					_ts bigint,
					_type varchar(8000),
					queryContext  varchar(8000),
					id varchar(8000),
					webPages varchar(8000),
					rankingResponse varchar(8000),
					webSearchUrl	varchar(8000)	'$.webPages.webSearchUrl',
					totalEstimatedMatches bigint	'$.webPages.totalEstimatedMatches'	,
					[value]			varchar(max)	'$.webPages.value'
				) AS Recs
OUTER APPLY OPENJSON ( [value] )
			WITH (	id		varchar(8000)	'$.value.id'	
					--,name			varchar(8000)	'$.value.name',	
					--url				varchar(8000)	'$.value.url'	,
					--isFamilyFriendly tinyint		'$.value.isFamilyFriendly',	
					--displayUrl		varchar(8000)	'$.value.displayUrl',		
					--description		varchar(8000)	'$.value.snippet',	
					--dateLastCrawled	datetime2		'$.value.dateLastCrawled',	
					--language		varchar(20)		'$.value.language',			
					--isNavigational	tinyint			'$.value.isNavigational'
				) AS r

WHERE recs.readLink is NULL


