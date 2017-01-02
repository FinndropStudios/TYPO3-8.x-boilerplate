<?php
$GLOBALS['TYPO3_CONF_VARS']['EXTCONF']['realurl'] = array(
    '_DEFAULT' => array(
        'init' => array(
            'appendMissingSlash' => 'ifNotFile,redirect',
            'emptyUrlReturnValue' => '/',
        ),
        'pagePath' => array(
            'rootpage_id' => '1',
        ),
        'fileName' => array(
            'defaultToHTMLsuffixOnPrev' => 0,
            'acceptHTMLsuffix' => 1,
            'index' => array(
                'print' => array(
                    'keyValues' => array(
                        'type' => 98,
                    ),
                ),
                'sitemap.xml' => array(
                    'keyValues' => array(
                        'type' => 841132,
                    ),
                ),
                'sitemap.txt' => array(
                    'keyValues' => array(
                        'type' => 841131,
                    ),
                ),
                'robots.txt' => array(
                    'keyValues' => array(
                        'type' => 841133,
                    ),
                ),
                '_DEFAULT' => array(
                    'keyValues' => array(
                        'type' => 0,
                    ),
                ),
            ),
        ),
        'preVars' => array(
            0 => array(
                'GETvar' => 'L',
                'valueMap' => array(
                    'en' => 1,
                ),
                'noMatch' => 'bypass',
            ),
        ),
        'postVarSets' => array(
            '_DEFAULT' => array(
                'search' => array(
                    array(
                        'GETvar' => 'tx_indexedsearch_pi2[action]'
                    ),
                ),
                'news' =>
                    array(
                        0 =>
                            array(
                                'GETvar' => 'tx_news_pi1[news]',
                                'lookUpTable' =>
                                    array(
                                        'table' => 'tx_news_domain_model_news',
                                        'id_field' => 'uid',
                                        'alias_field' => 'title',
                                        'addWhereClause' => ' AND NOT deleted',
                                        'useUniqueCache' => 1,
                                        'useUniqueCache_conf' =>
                                            array(
                                                'strtolower' => 1,
                                                'spaceCharacter' => '-',
                                            ),
                                    ),
                            ),
                    ),
            ),
        ),
    ),
);

# 404-handling
$GLOBALS['TYPO3_CONF_VARS']['FE']['pageNotFound_handling'] = '/seite-nicht-gefunden/';
$GLOBALS['TYPO3_CONF_VARS']['FE']['pageNotFound_handling_statheader'] = 'HTTP/1.0 404 Not Found';

# Activate RealURL on every desired environment
# $GLOBALS['TYPO3_CONF_VARS']['EXTCONF']['realurl']['DOMAINHERE'] = $GLOBALS['TYPO3_CONF_VARS']['EXTCONF']['realurl']['default'];
# $GLOBALS['TYPO3_CONF_VARS']['EXTCONF']['realurl']['DOMAINHERE']['pagePath']['rootpage_id'] = 1;
# $GLOBALS['TYPO3_CONF_VARS']['EXTCONF']['realurl']['DOMAINHERE'] = $GLOBALS['TYPO3_CONF_VARS']['EXTCONF']['realurl']['DOMAINHERE'];
