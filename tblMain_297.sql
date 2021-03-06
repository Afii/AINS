/*** Script for UK Mandating Publishers (ASSumption: delegate=CLA == MandateDelegateID which is always 1 !! needs further checking)
CAROLINE applicable license sets
ONLY Active status publishers ***/

SELECT
 party.PartyId ,[PartyName], PartyRoleId
 
 ,country.MappingNeilsens as Country

 ,man.mandateid as manMandateID, man.countryid
 , manifTYPrul.ManifestationTypeId
 , manrul.LicenceSetId, manif.Title as exTitles,WebLookupFormDesc as PrintDigital,  pubType.ShortDescription as ManifestationType
 ,tblOPT.opt
	 ,convert(date,EffectiveFrom) as EffectiveFROM, convert(date,EffectiveTo) as EffectiveTO


	, Case when left(licSet.Code,2)='ED' then 'Education' 
			 else case when left(licset.code,2)='HE' then 'Higher Education' else 'Business' end end as LicenseSetType
			 ,IsIncludeRule as IncEx
	
	,RuleTitle
   	,RuleDescription



  FROM [OPS_LIVE_RO].[dbo].[Party] as party with(nolock) 
			left outer join [OPS_LIVE_RO].[dbo].[Mandate] as man with(nolock) on party.PartyId=man.MandateDelegatorId


			left outer join [OPS_LIVE_RO].[dbo].[MandateRule] as manrul with(nolock) on man.MandateId=manrul.MandateId
			left outer join [OPS_LIVE_RO].[dbo].[ManifestationRule] as manifrul with(nolock) on manrul.MandateRuleId=manifrul.MandateRuleId
			left outer join [OPS_LIVE_RO].[dbo].[Manifestation] as manif with(nolock) on manif.ManifestationId=manifrul.ManifestationId
			left outer join [OPS_LIVE_RO].[dbo].[lkpLicenceSet] as LicSet with(nolock) on LicSet.LicenceSetId=manrul.LicenceSetId
			left outer join [OPS_LIVE_RO].[dbo].[lkpcountry] as country with(nolock) on man.CountryId=country.CountryId 
			left outer join [OPS_LIVE_RO].[dbo].[lkpPublicationType] as pubType with(nolock) on pubType.ManifestationTypeId=manif.ManifestationTypeId
			left outer join [OPS_LIVE_RO].[dbo].[ManifestationTypeRule] as manifTYPrul with(nolock) on manrul.MandateRuleId=manifTYPrul.MandateRuleId
			left outer join [OPS_LIVE_RO].[dbo].[lkpManifestationType] as ManiTyp with(nolock) on manifTYPrul.ManifestationTypeId=ManiTyp.ManifestationTypeId 
			left outer join (select partyid, count(convert(int,IsIncludeRule)) as opt 
								from [OPS_LIVE_RO].[dbo].[Party] as party2 left outer join [OPS_LIVE_RO].[dbo].[Mandate] as man2 
									on party2.PartyId=man2.MandateDelegatorId
									left outer join [OPS_LIVE_RO].[dbo].[MandateRule] as manrul2 on man2.MandateId=manrul2.MandateId
								where PartyRoleId=3 and man2.CountryId=1 and PartyStatusId=1
								group by PartyId) as tblOPT on tblOPT.PartyId=party.PartyId/**Count of IsIncludeRule flag against a publisher**/


  where PartyRoleId=3 and man.CountryId=1 and 
  PartyStatusId=1
				and 
					man.MandateId=(select max(mandateid) /**picking the latest license set only - requested by CL**/
						from [OPS_LIVE_RO].[dbo].[Mandate] as man_1 join [OPS_LIVE_RO].[dbo].[Party] as party_1 on man_1.MandateDelegatorId=party_1.PartyId
						where party_1.PartyId=party.PartyId) 

				--and charindex('include: named manifestations',lower(RuleDescription))= 0 /**excluding license sets with this title, Caroline beleived these are wrong and creating confusion**/
	
				--and 
				--	 case when charindex('Manifestation',RuleDescription)>0 /**list of License sets to include - set by Caroline Last on 25SEP2018**/
				--				then left(RuleDescription,charindex('Manifestation',RuleDescription)+13) 
				--						else RuleDescription end in 
				--	('Business Digital - Exclude: Named Manifestation',
				--			'Business Photocopying - Include: Named Manifestation',
				--			'Business Scanning - Include: Named Manifestation',
				--			'Business Extended Multinational Digital - Exclude: Named Manifestation',
				--			'Business Extended Multinational Photocopying - Include: Named Manifestation',
				--			'Business Extended Multinational Scanning - Include: Named Manifestation',
				--			'Business Multinational Digital - Exclude: Named Manifestation',
				--			'Business Multinational Photocopying - Include: Named Manifestation',
				--			'Business Multinational Scanning - Include: Named Manifestation',
				--			'Law Digital - Exclude: Named Manifestation',
				--			'Law Photocopying - Include: Named Manifestation',
				--			'Law Scanning - Include: Named Manifestation',
				--			'Law Extended Multinational Digital - Exclude: Named Manifestation',
				--			'Law Extended Multinational Photocopying - Include: Named Manifestation',
				--			'Law Extended Multinational Scanning - Include: Named Manifestation',
				--			'Law Multinational Digital - Exclude: Named Manifestation',
				--			'Law Multinational Photocopying - Include: Named Manifestation',
				--			'Law Multinational Scanning - Include: Named Manifestation',
				--			'Pharmaceutical Digital - Exclude: Named Manifestation',
				--			'Pharmaceutical Photocopying - Include: Named Manifestation',
				--			'Pharmaceutical Scanning - Include: Named Manifestation',
				--			'Pharmaceutical Extended Multinational Digital - Exclude: Named Manifestation',
				--			'Pharmaceutical Extended Multinational Photocopying - Include: Named Manifestation',
				--			'Pharmaceutical Extended Multinational Scanning - Include: Named Manifestation',
				--			'Pharmaceutical Multinational Digital - Exclude: Named Manifestation',
				--			'Pharmaceutical Multinational Photocopying - Include: Named Manifestation',
				--			'Pharmaceutical Multinational Scanning - Include: Named Manifestation',
				--			'Public Administration Digital - Exclude: Named Manifestation',
				--			'Public Administration Photocopying - Include: Named Manifestation',
				--			'Public Administration Scanning - Include: Named Manifestation',
				--			'Website Republishing Business - Exclude: Named Manifestation',
				--			'Website Republishing Public Administration - Exclude: Named Manifestation',
				--			'Education Digital - Exclude: Named Manifestation',
				--			'Education Photocopying - Include: Named Manifestation',
				--			'Education Scanning - Include: Named Manifestation',
				--			'Higher Education - Second Chapter - Exclude: Named Manifestation',
				--			'Higher Education Digital - Exclude: Named Manifestation',
				--			'Higher Education Photocopying - Include: Named Manifestation') 


				--and case when left(licset.Code,3) in ('bld','web','pha','law','bus') 
				--	or left(licset.code,2) in ('pa','he','ed') 
				--	then 1 else 0 end = 1 
				--	and 
				--	case when charindex('Include',RuleDescription)>6 and charindex('Photocopy',RuleDescription)>0 
				--		or charindex('Include',RuleDescription)>6 and charindex('Scan',RuleDescription)>0 
				--		or charindex('Exclude',RuleDescription)>6 and charindex('Digital',RuleDescription)>0 
				--		or charindex('Exclude',RuleDescription)>6 and charindex('Website',RuleDescription)>0 
				--		or charindex('Exclude',RuleDescription)>6 and charindex('Second Chapter',RuleDescription)>0  then 1 else 0 end = 1
  
  order by partyid, PrintDigital
  
    

  

