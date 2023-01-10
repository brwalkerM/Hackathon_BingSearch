-- Explore Records
SELECT * 
FROM dbo.BingSearch_Results_Youtube




-- Parse Records to make a view consumable by PBI
-- https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/query/getting-started
		--SELECT 
		----readLink,
		----LEN(readLink) as length_,
		----PATINDEX('%.com%',readLink) as StartPt,
		----PATINDEX('% site:%',readLink) as EndPt,
		----(PATINDEX('%.com%',readLink))-(PATINDEX('% site:%',readLink)+6) as SubstringCharCount,
		--SUBSTRING(readLink, (PATINDEX('% site:%',readLink)+6),(PATINDEX('%.com%',readLink)-(PATINDEX('% site:%',readLink)+6))) + '-'+ _type as AssetType,
		--SUBSTRING(readLink, (PATINDEX('%=%',readLink)+1), (PATINDEX('% site:%',readLink)-PATINDEX('%=%',readLink)-1)) as SearchTerm
		--FROM dbo.BingSearch_Results_Youtube yt

		-- FInd Asset Type and Term
		--SELECT	SUBSTRING(readLink, (PATINDEX('% site:%',readLink)+6),(PATINDEX('%.com%',readLink)-(PATINDEX('% site:%',readLink)+6))) + '-'+ _type as AssetType,
		--		SUBSTRING(readLink, (PATINDEX('%=%',readLink)+1), (PATINDEX('% site:%',readLink)-PATINDEX('%=%',readLink)-1)) as SearchTerm
		--FROM dbo.BingSearch_Results_Youtube yt



-- Parse the information stored in the array field named [Value]
-- https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/query-cosmos-db-analytical-store?tabs=openrowset-key

		CREATE VIEW dbo.YoutubeResultsParsed
		as
		SELECT	SUBSTRING(readLink, (PATINDEX('% site:%',readLink)+6),(PATINDEX('%.com%',readLink)-(PATINDEX('% site:%',readLink)+6))) + '-'+ _type as AssetType,
				SUBSTRING(readLink, (PATINDEX('%=%',readLink)+1), (PATINDEX('% site:%',readLink)-PATINDEX('%=%',readLink)-1)) as SearchTerm,
				*
		FROM	OPENROWSET( 
						PROVIDER = 'CosmosDB',
						CONNECTION = N'account=cdb-bs;database=BingSearch_Results;region=;',
						OBJECT = N'Youtube',
						SERVER_CREDENTIAL = N'CosmosDB_cdb-bs'
					)  
				WITH (	readLink varchar(8000),
						_type varchar(8000),
						[value]  varchar(max) ) AS Recs
		        OUTER APPLY OPENJSON ( [value] )
		                    WITH (	webSearchUrl		varchar(8000),	
									name				varchar(8000),	
									description			varchar(8000)	,
									thumbnailUrl		varchar(4000),	
									datePublished		datetime2,		
									publisher			varchar(4000) '$.publisher.name',	
									creator				varchar(4000) '$.creator.name',	
									isAccessibleForFree	tinyint,			
									isFamilyFriendly	tinyint,			
									contentUrl			varchar(4000),	
									hostPageUrl			varchar(4000),	
									encodingFormat		varchar(4000),	
									hostPageDisplayUrl	varchar(4000),	
									width				int	,			
									height				int,				
									duration			varchar(4000),	
									motionThumbnailUrl	varchar(4000),	
									embedHtml			varchar(4000),	
									allowHttpsEmbed		tinyint,			
									viewCount			int,				
									thumbnail_width		varchar(4000) '$.thumbnail.width',
									thumbnail_height	varchar(4000) '$.thumbnail.height',
									videoId				varchar(4000),	
									allowMobileEmbed	tinyint,			
									isSuperfresh		tinyint ) AS videos

SELECT * FROM dbo.YoutubeResultsParsed

-- Create A PBI friendly View
		--CREATE VIEW dbo.YoutubeResult_PBI
		--AS
		--SELECT [AssetType]
		--      ,[SearchTerm]
		--      ,[name]
		--      ,[description]
		--      ,CAST([datePublished] as DATE) as datePublished
		--      ,[creator]
		--      ,[contentUrl]
		--      ,[duration]
		--      ,[viewCount]
		--      ,[videoId]
		--  FROM [dbo].[YoutubeResultsParsed]

SELECT * FROM dbo.YoutubeResult_PBI