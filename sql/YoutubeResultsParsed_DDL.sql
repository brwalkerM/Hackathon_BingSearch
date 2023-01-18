/****** Object:  View [dbo].[YoutubeResultsParsed]    Script Date: 1/18/2023 7:22:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[YoutubeResultsParsed]
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

GO


