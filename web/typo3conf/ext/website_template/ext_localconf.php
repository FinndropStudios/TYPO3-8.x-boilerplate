<?php

/**
 * @var $_EXTKEY string
 */

if(!defined('TYPO3_MODE')) {
	die('Access denied.');
}

/*****
 * Page TS
 */
\TYPO3\CMS\Core\Utility\ExtensionManagementUtility::addPageTSConfig('<INCLUDE_TYPOSCRIPT: source="FILE:EXT:' . $_EXTKEY . '/Configuration/PageTypoScript/page_ts.t3s">');

$iconRegistry = \TYPO3\CMS\Core\Utility\GeneralUtility::makeInstance(\TYPO3\CMS\Core\Imaging\IconRegistry::class);

$iconRegistry->registerIcon(
    'volume-up',
    \TYPO3\CMS\Core\Imaging\IconProvider\FontawesomeIconProvider::class,
    [
        'name'     => 'volume-up'
    ]
);
