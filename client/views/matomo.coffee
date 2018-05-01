if Meteor.isClient
    Meteor.startup ->
        matomoUrl = Meteor.settings?.public?.matomoUrl
        matomoSiteId = Meteor.settings?.public?.matomoSiteId

        if matomoUrl and matomoSiteId
            console.debug('Loading Matomo', matomoUrl, matomoSiteId)
            loadMatomo = ->
                _paq.push(['setTrackerUrl', matomoUrl + 'piwik.php']);
                _paq.push(['setSiteId', matomoSiteId]);
                g = document.createElement('script')
                s = document.getElementsByTagName('script')[0];
                g.type = 'text/javascript'; g.async = true; g.defer = true; g.src = matomoUrl + 'piwik.js'; s.parentNode.insertBefore(g, s);
            loadMatomo()

            currentUrl = location.href
            Router.onAfterAction -> Meteor.defer ->
                _paq.push(['setReferrerUrl', currentUrl])
                currentUrl = '' + window.location.href
                _paq.push(['setCustomUrl', currentUrl])
                _paq.push(['setDocumentTitle', document.location.pathname])

                _paq.push(['deleteCustomVariables', 'page'])
                _paq.push(['setGenerationTimeMs', 0])
                _paq.push(['trackPageView'])

                content = $('.content-container').get()?[0]
                if content
                    _paq.push(['MediaAnalytics::scanForMedia', content])
                    _paq.push(['FormAnalytics::scanForForms', content])
                    _paq.push(['trackContentImpressionsWithinNode', content])

        else console.debug('Matomo integration not configured.')